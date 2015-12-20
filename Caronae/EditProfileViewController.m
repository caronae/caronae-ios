#import <AFNetworking/AFNetworking.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "CaronaeAlertController.h"
#import "EditProfileViewController.h"
#import "ZoneSelectionViewController.h"

@interface EditProfileViewController () <ZoneSelectionDelegate>
@property (nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic) NSDateFormatter *joinedDateFormatter;
@property (nonatomic) UIBarButtonItem *loadingButton;
@property (nonatomic) NSString *neighborhood;
@property (weak, nonatomic) IBOutlet UIView *fbButtonView;
@property (nonatomic) NSString *photoURL;
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([FBSDKAccessToken currentAccessToken]) {
        // User is logged in, do work such as go to next view controller.
        FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
        NSLog(@"User is logged in on Facebook with ID %@", token.userID);
    }
    
    [self updateProfileFields];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.loadingButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    [self.fbButtonView addSubview:loginButton];
    loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.fbButtonView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[loginButton]|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(loginButton)]];
    [self.fbButtonView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[loginButton]|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(loginButton)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FBTokenChanged:) name:FBSDKAccessTokenDidChangeNotification object:nil];
}

- (IBAction)didTapCancelButton:(id)sender {
    CaronaeAlertController *alert = [CaronaeAlertController alertControllerWithTitle:@"Cancelar edição do perfil?"
                                                                             message:@"Quaisquer mudanças não salvas serão perdidas."
                                                                      preferredStyle:SDCAlertControllerStyleAlert];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Não" style:SDCAlertActionStyleCancel handler:nil]];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancelar" style:SDCAlertActionStyleDestructive handler:^(SDCAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alert presentWithCompletion:nil];
}

- (void)updateProfileFields {
    NSDictionary *user = [CaronaeDefaults defaults].user;
    self.user = user;
    
    NSDateFormatter *joinedDateParser = [[NSDateFormatter alloc] init];
    joinedDateParser.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *joinedDate = [joinedDateParser dateFromString:user[@"created_at"]];
    self.joinedDateFormatter = [[NSDateFormatter alloc] init];
    self.joinedDateFormatter.dateFormat = @"MM/yyyy";
    
    self.nameLabel.text = user[@"name"];
    self.courseLabel.text = user[@"course"];
    
    self.joinedDateLabel.text = [self.joinedDateFormatter stringFromDate:joinedDate];
    
    self.emailTextField.text = user[@"email"];
    self.phoneTextField.text = user[@"phone_number"];
    
    self.neighborhood = user[@"location"];
    if (![self.neighborhood isEqualToString:@""]) {
        [self.neighborhoodButton setTitle:self.neighborhood forState:UIControlStateNormal];
    }
    else {
        [self.neighborhoodButton setTitle:@"Bairro" forState:UIControlStateNormal];
    }
    
    self.hasCarSwitch.on = [user[@"car_owner"] isEqual:@(YES)];
    
    self.carPlateTextField.text = user[@"car_plate"];
    self.carModelTextField.text = user[@"car_model"];
    self.carColorTextField.text = user[@"car_color"];
    
    self.photoURL = user[@"profile_pic_url"];
    if (self.photoURL) {
        [self.photo sd_setImageWithURL:[NSURL URLWithString:self.photoURL]
                     placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                              options:SDWebImageRefreshCached];
    }
}

- (IBAction)didTapSaveButton:(id)sender {
    NSDictionary *updatedUser = [self generateUserDictionaryFromView];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [self showLoadingHUD:YES];

    [manager PUT:[CaronaeAPIBaseURL stringByAppendingString:@"/user"] parameters:updatedUser success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self showLoadingHUD:NO];
        
        NSLog(@"User updated.");
        NSMutableDictionary *newUpdatedUser = [[NSMutableDictionary alloc] initWithDictionary:self.user];
        newUpdatedUser[@"name"] = updatedUser[@"name"];
        newUpdatedUser[@"course"] = updatedUser[@"course"];
        newUpdatedUser[@"profile"] = updatedUser[@"profile"];
        newUpdatedUser[@"phone_number"] = updatedUser[@"phone_number"];
        newUpdatedUser[@"email"] = updatedUser[@"email"];
        newUpdatedUser[@"car_owner"] = updatedUser[@"car_owner"];
        newUpdatedUser[@"car_model"] = updatedUser[@"car_model"];
        newUpdatedUser[@"car_plate"] = updatedUser[@"car_plate"];
        newUpdatedUser[@"car_color"] = updatedUser[@"car_color"];
        newUpdatedUser[@"location"] = updatedUser[@"location"];
        newUpdatedUser[@"profile_pic_url"] = _photoURL ? _photoURL : @"";
        self.user = newUpdatedUser;
        
        [CaronaeDefaults defaults].user = newUpdatedUser;
        
        if ([self.delegate respondsToSelector:@selector(didUpdateUser:)]) {
            [self.delegate didUpdateUser:newUpdatedUser];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showLoadingHUD:NO];
        NSLog(@"Error: %@", error.description);
        [CaronaeAlertController presentOkAlertWithTitle:@"Erro atualizando perfil" message:@"Ocorreu um erro salvando as alterações no seu perfil."];
    }];
}

- (NSDictionary *)generateUserDictionaryFromView {
    NSDictionary *updatedUser = @{
                                  @"name": self.user[@"name"],
                                  @"profile": self.user[@"profile"],
                                  @"course": self.user[@"course"],
                                  @"phone_number": self.phoneTextField.text,
                                  @"email": self.emailTextField.text,
                                  @"car_owner": @(self.hasCarSwitch.on),
                                  @"car_model": self.carModelTextField.text,
                                  @"car_plate": self.carPlateTextField.text,
                                  @"car_color": self.carColorTextField.text,
                                  @"location": self.neighborhood,
                                  @"profile_pic_url": _photoURL ? _photoURL : @""
                                  };
    
    return updatedUser;
}

#pragma mark - Zone selection methods

- (void)hasSelectedNeighborhood:(NSString *)neighborhood inZone:(NSString *)zone {
    NSLog(@"User has selected %@ in %@", neighborhood, zone);
    self.neighborhood = neighborhood;
    [self.neighborhoodButton setTitle:self.neighborhood forState:UIControlStateNormal];
}


#pragma mark - IBActions

- (IBAction)didTapPhoto:(id)sender {
    // TODO: support for iOS 7
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"De onde deseja importar sua foto?" preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Usar foto do Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self importPhotoFromFacebook];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Remover minha foto" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Removendo foto...");
        _photoURL = nil;
        _photo.image = [UIImage imageNamed:@"Profile Picture"];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewZones"]) {
        ZoneSelectionViewController *vc = segue.destinationViewController;
        vc.type = ZoneSelectionZone;
        vc.delegate = self;
    }
}


#pragma mark - Etc

- (void)showLoadingHUD:(BOOL)loading {
    if (!loading) {
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = self.loadingButton;
    }
}


#pragma mark - Facebook integration

- (void)FBTokenChanged:(NSNotification *)notification {
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    NSLog(@"Facebook Access Token did change. New access token is %@", token.tokenString);
    
    if (notification.userInfo[FBSDKAccessTokenDidChangeUserID]) {
        id fbID;
        if (token.userID) {
            NSLog(@"Facebook has loogged in with Facebook ID %@.", token.userID);
            fbID = token.userID;
        }
        else {
            NSLog(@"User has logged out from Facebook.");
            fbID = [NSNull null];
        }
        
        [self updateUsersFacebookID:fbID success:^(id responseObject) {
            NSLog(@"Updated user's Facebook ID on server.");
        } failure:^(NSError *error) {
            NSLog(@"Error updating user's Facebook ID on server: %@", error.localizedDescription);
        } tries:3];
    }
}

- (void)updateUsersFacebookID:(id)fbID success:(void (^)(id responseObject))success                       failure:(void (^)(NSError *error))failure tries:(NSUInteger)times {
    if (times <= 0) {
        failure([NSError errorWithDomain:CaronaeErrorDomain code:3 userInfo:@{@"localizedDescription":@"Failed updating user's Facebook ID remotely."}]);
    }
    else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
        
        [manager PUT:[CaronaeAPIBaseURL stringByAppendingString:@"/user/saveFaceId"] parameters:@{@"id": fbID} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(operation);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self updateUsersFacebookID:fbID success:success failure:failure tries:times-1];
        }];
    }
}

- (void)importPhotoFromFacebook {
    NSLog(@"Importing profile picture from Facebook...");
    
    [SVProgressHUD show];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"me/picture?type=large&redirect=false"]
                                  parameters:@{@"fields": @"url"}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            NSDictionary *data = result[@"data"];
            _photoURL = data[@"url"];
            [_photo sd_setImageWithURL:[NSURL URLWithString:_photoURL]
                          placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                                   options:SDWebImageRefreshCached];
        }
        else {
            NSLog(@"result: %@", error.description);
            [CaronaeAlertController presentOkAlertWithTitle:@"Erro atualizando foto" message:@"Não foi possível obter sua foto de perfil do Facebook."];
        }
    }];
}


@end
