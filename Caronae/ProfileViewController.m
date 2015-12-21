#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ProfileViewController.h"
#import "CaronaeAlertController.h"
#import "EditProfileViewController.h"
#import "MenuViewController.h"

@interface ProfileViewController () <EditProfileDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIButton *signoutButton;
@property (nonatomic) NSDateFormatter *joinedDateFormatter;
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
        _carPlateLabel.text = _user[@"car_plate"];
        _carModelLabel.text = _user[@"car_model"];
        _carColorLabel.text = _user[@"car_color"];
        [_mutualFriendsView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    }
    else {
        self.title = _user[@"name"];
        [_carDetailsView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        [_signoutButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        self.navigationItem.rightBarButtonItem = nil;
        [self updateMutualFriends];
    }
    
    if (_user[@"created_at"]) {
        NSDateFormatter *joinedDateParser = [[NSDateFormatter alloc] init];
        joinedDateParser.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *joinedDate = [joinedDateParser dateFromString:_user[@"created_at"]];
        _joinedDateFormatter = [[NSDateFormatter alloc] init];
        _joinedDateFormatter.dateFormat = @"MM/yyyy";
        _joinedDateLabel.text = [self.joinedDateFormatter stringFromDate:joinedDate];
    }
    
    _nameLabel.text = _user[@"name"];
    _courseLabel.text = _user[@"course"];
    
    if (_user[@"profile_pic_url"] && ![_user[@"profile_pic_url"] isEqualToString:@""]) {
        [self.profileImage sd_setImageWithURL:[NSURL URLWithString:_user[@"profile_pic_url"]]
                      placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                               options:SDWebImageRefreshCached];
    }
    
    [self updateRidesOfferedCount];
}

- (void)updateRidesOfferedCount {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:[NSString stringWithFormat:@"/ride/getRidesHistoryCount/%@", _user[@"id"]]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger numDrives = [responseObject[@"offeredCount"] integerValue];
        NSInteger numRides = [responseObject[@"takenCount"] integerValue];
        
        NSLog(@"User has offered %ld and taken %ld rides.", numDrives, numRides);
        
        _numDrivesLabel.text = [NSString stringWithFormat:@"%ld", numDrives];
        _numRidesLabel.text = [NSString stringWithFormat:@"%ld", numRides];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error reading history count for user: %@", error.localizedDescription);
    }];
}

- (void)updateMutualFriends {
    NSString *facebookID = _user[@"face_id"];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"/%@", facebookID]
                                  parameters:@{@"fields": @"context.fields(mutual_friends)"}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
            NSArray *friends = result[@"context"][@"mutual_friends"][@"data"];
            NSLog(@"%@", friends);
            _mutualFriendsLabel.text = [NSString stringWithFormat:@"Amigos em comum: %lu", friends.count];
        }
        else {
            NSLog(@"Error updating friends in common: %@", error.description);
        }
    }];
}


#pragma mark - Edit profile methods

- (void)didUpdateUser:(NSDictionary *)newUser {
    _user = newUser;
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
}
@end
