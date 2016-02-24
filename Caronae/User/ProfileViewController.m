#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "CaronaeAlertController.h"
#import "EditProfileViewController.h"
#import "FalaeViewController.h"
#import "MenuViewController.h"
#import "ProfileViewController.h"
#import "RiderCell.h"

@interface ProfileViewController () <EditProfileDelegate, UICollectionViewDataSource>
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
}

- (BOOL)isMyProfile {
    UINavigationController *navigationVC = self.navigationController;
    if (navigationVC.viewControllers.count >= 2) {
        UIViewController *previousVC = navigationVC.viewControllers[navigationVC.viewControllers.count - 2];
        if ([previousVC isKindOfClass:[MenuViewController class]]) {
            return true;
        }
    }
    return false;
}

- (void)updateProfileFields {
    if ([self isMyProfile]) {
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
    _courseLabel.text = [NSString stringWithFormat:@"%@ | %@", _user.profile, _user.course];
    _numDrivesLabel.text = _user.numDrives > -1 ? [NSString stringWithFormat:@"%d", _user.numDrives] : @"-";
    _numRidesLabel.text = _user.numRides > -1 ? [NSString stringWithFormat:@"%d", _user.numRides] : @"-";
    
    if (_user.profilePictureURL && ![_user.profilePictureURL isEqualToString:@""]) {
        [self.profileImage sd_setImageWithURL:[NSURL URLWithString:_user.profilePictureURL]
                      placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                               options:SDWebImageRefreshCached | SDWebImageRetryFailed];
    }
    
    [self updateRidesOfferedCount];
}

- (void)updateRidesOfferedCount {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:[NSString stringWithFormat:@"/ride/getRidesHistoryCount/%@", _user.userID]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int numDrives = [responseObject[@"offeredCount"] intValue];
        int numRides = [responseObject[@"takenCount"] intValue];
        
        _numDrivesLabel.text = [NSString stringWithFormat:@"%d", numDrives];
        _numRidesLabel.text = [NSString stringWithFormat:@"%d", numRides];
        
        _user.numDrives = numDrives;
        _user.numRides = numRides;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error reading history count for user: %@", error.localizedDescription);
    }];
}

- (void)updateMutualFriends {
    // Abort if the Facebook accounts are not connected.
    if (![CaronaeDefaults userFBToken] || !_user.facebookID || [_user.facebookID isEqualToString:@""]) {
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:[CaronaeDefaults userFBToken] forHTTPHeaderField:@"Facebook-Token"];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:[NSString stringWithFormat:@"/user/%@/mutualFriends", _user.facebookID]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *mutualFriendsJSON = responseObject[@"mutual_friends"];
        
        NSError *error;
        NSArray<User *> *mutualFriends = [MTLJSONAdapter modelsOfClass:User.class fromJSONArray:mutualFriendsJSON error:&error];
        
        if (error) {
            NSLog(@"Error parsing user from mutual friends: %@", error.localizedDescription);
        }
        
        self.mutualFriends = mutualFriends;
        
        [self.mutualFriendsCollectionView reloadData];
        _mutualFriendsLabel.text = [NSString stringWithFormat:@"Amigos em comum: %d", [responseObject[@"total_count"] intValue]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error loading mutual friends for user: %@", error.localizedDescription);
    }];
}


#pragma mark - Edit profile methods

- (void)didUpdateUser:(User *)updatedUser {
    self.user = updatedUser;
    [self updateProfileFields];
}


#pragma mark - IBActions

- (IBAction)didTapLogoutButton:(id)sender {
    CaronaeAlertController *alert = [CaronaeAlertController alertControllerWithTitle:@"Você deseja mesmo sair da sua conta?"
                                                                             message:@"Para entrar novamente você precisará do token de autorização gerado pelo SIGA."
                                                                      preferredStyle:SDCAlertControllerStyleAlert];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancelar" style:SDCAlertActionStyleCancel handler:nil]];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Sair" style:SDCAlertActionStyleDestructive handler:^(SDCAlertAction *action){
        [CaronaeDefaults signOut];
    }]];
    [alert presentWithCompletion:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditProfile"]) {
        UINavigationController *navigationVC = segue.destinationViewController;
        EditProfileViewController *vc = (EditProfileViewController *)navigationVC.topViewController;
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"ReportUser"]) {
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
    User *user = _mutualFriends[indexPath.row];
    
    RiderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Friend Cell" forIndexPath:indexPath];
    
    cell.user = user;
    cell.nameLabel.text = user.firstName;
    
    if (user.profilePictureURL && ![user.profilePictureURL isEqualToString:@""]) {
        [cell.photo sd_setImageWithURL:[NSURL URLWithString:user.profilePictureURL]
                      placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                               options:SDWebImageRefreshCached | SDWebImageRetryFailed];
    }
    
    return cell;
}

@end
