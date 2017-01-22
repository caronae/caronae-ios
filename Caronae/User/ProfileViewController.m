@import FBSDKCoreKit;
#import "CaronaeAlertController.h"
#import "EditProfileViewController.h"
#import "FalaeViewController.h"
#import "MenuViewController.h"
#import "ProfileViewController.h"
#import "RiderCell.h"
#import "SHSPhoneNumberFormatter+UserConfig.h"
#import "UIImageView+crn_setImageWithURL.h"
#import "Caronae-Swift.h"

@interface ProfileViewController () <UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIButton *signoutButton;
@property (weak, nonatomic) IBOutlet UIView *reportView;
@property (nonatomic) NSDateFormatter *joinedDateFormatter;
@property (nonatomic) NSArray<User *> *mutualFriends;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateProfileFields];
    
    if ([UserService.instance.user isEqual:_user]) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateProfileFields) name:CaronaeDidUpdateUserNotification object:nil];
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)updateProfileFields {
    User *currentUser = UserService.instance.user;
    if (!currentUser) {
        return;
    }
    
    if ([currentUser isEqual:_user]) {
        self.title = @"Meu Perfil";
        
        if (_user.carOwner) {
            _carPlateLabel.text = _user.carPlate;
            _carModelLabel.text = _user.carModel;
            _carColorLabel.text = _user.carColor;
        }
        else {
            _carPlateLabel.text = @"-";
            _carModelLabel.text = @"-";
            _carColorLabel.text = @"-";
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mutualFriendsView removeFromSuperview];
            [_reportView removeFromSuperview];
        });
    }
    else {
        self.title = _user.name;
        self.navigationItem.rightBarButtonItem = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_carDetailsView removeFromSuperview];
            [_signoutButton removeFromSuperview];
        });
        [self updateMutualFriends];
    }
    
    if (_user.createdAt) {
        _joinedDateFormatter = [[NSDateFormatter alloc] init];
        _joinedDateFormatter.dateFormat = @"MM/yyyy";
        _joinedDateLabel.text = [self.joinedDateFormatter stringFromDate:_user.createdAt];
    }
    
    _nameLabel.text = _user.name;
    _courseLabel.text = _user.course.length > 0 ? [NSString stringWithFormat:@"%@ | %@", _user.profile, _user.course] : _user.profile;
    _numDrivesLabel.text = _user.numDrives > -1 ? [NSString stringWithFormat:@"%ld", (long)_user.numDrives] : @"-";
    _numRidesLabel.text = _user.numRides > -1 ? [NSString stringWithFormat:@"%ld", (long)_user.numRides] : @"-";
    
    if (_user.phoneNumber.length > 0) {
        SHSPhoneNumberFormatter *phoneFormatter = [[SHSPhoneNumberFormatter alloc] init];
        [phoneFormatter setDefaultOutputPattern:Caronae8PhoneNumberPattern];
        [phoneFormatter addOutputPattern:Caronae9PhoneNumberPattern forRegExp:@"[0-9]{12}\\d*$"];
        NSDictionary *result = [phoneFormatter valuesForString:_user.phoneNumber];
        NSString *formattedPhoneNumber = result[@"text"];
        [_phoneButton setTitle:formattedPhoneNumber forState:UIControlStateNormal];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_phoneView removeFromSuperview];
        });
    }
    
    if (_user.profilePictureURL.length > 0) {
        [self.profileImage crn_setImageWithURL:[NSURL URLWithString:_user.profilePictureURL]];
    }
    
    [self updateRidesOfferedCount];
}

- (void)updateRidesOfferedCount {
    [UserService.instance ridesCountForUserWithID:_user.id success:^(NSInteger offeredCount, NSInteger takenCount) {
        _numDrivesLabel.text = [NSString stringWithFormat:@"%ld", (long)offeredCount];
        _numRidesLabel.text = [NSString stringWithFormat:@"%ld", (long)takenCount];
    } error:^(NSError * _Nonnull error) {
        NSLog(@"Error reading history count for user: %@", error.localizedDescription);
    }];
}

- (void)updateMutualFriends {
    [UserService.instance mutualFriendsForUserWithFacebookID:_user.facebookID success:^(NSArray<User *> * _Nonnull mutualFriends, NSInteger totalCount) {
        self.mutualFriends = mutualFriends;
        [self.mutualFriendsCollectionView reloadData];
        
        if (totalCount > 0) {
            _mutualFriendsLabel.text = [NSString stringWithFormat:@"Amigos em comum: %ld no total e %ld no Caronaê", (long)totalCount, (long)mutualFriends.count];
        } else {
            _mutualFriendsLabel.text = @"Amigos em comum: 0";
        }
    } error:^(NSError * _Nonnull error) {
        NSLog(@"Error loading mutual friends for user: %@", error.localizedDescription);
    }];
}


#pragma mark - IBActions

- (IBAction)didTapPhoneButton:(id)sender {
    NSString *phoneNumber = _user.phoneNumber;
    NSString *phoneNumberURLString = [NSString stringWithFormat:@"telprompt://%@", phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumberURLString]];
}

- (IBAction)didTapLogoutButton:(id)sender {
    CaronaeAlertController *alert = [CaronaeAlertController alertControllerWithTitle:@"Você deseja mesmo sair da sua conta?"
                                                                             message: nil
                                                                      preferredStyle:SDCAlertControllerStyleAlert];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancelar" style:SDCAlertActionStyleCancel handler:nil]];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Sair" style:SDCAlertActionStyleDestructive handler:^(SDCAlertAction *action){
        [UserService.instance signOut];
    }]];
    [alert presentWithCompletion:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ReportUser"]) {
        FalaeViewController *vc = segue.destinationViewController;
        [vc setReport:_user];
    }
}


#pragma mark - Collection methods (Mutual friends)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _mutualFriends.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RiderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Friend Cell" forIndexPath:indexPath];
    
    User *user = _mutualFriends[indexPath.row];
    [cell configureWithUser:user];
    
    return cell;
}

@end
