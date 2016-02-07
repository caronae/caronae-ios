#import <AFNetworking/AFNetworking.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "CaronaeTextField.h"
#import "NSString+validation.h"
#import "CaronaeAlertController.h"
#import "EditProfileViewController.h"
#import "ZoneSelectionViewController.h"

@interface EditProfileViewController () <ZoneSelectionDelegate, UIActionSheetDelegate>
@property (nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic) NSDateFormatter *joinedDateFormatter;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic) UIBarButtonItem *loadingButton;
@property (weak, nonatomic) IBOutlet UIButton *changePhotoButton;
@property (nonatomic) NSString *neighborhood;
@property (weak, nonatomic) IBOutlet UIView *fbButtonView;
@property (nonatomic) NSString *photoURL;
@property (nonatomic) CGFloat carDetailsHeightOriginal;
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
        NSLog(@"User is logged in on Facebook with ID %@", token.userID);
    }
    
    [self.phoneTextField.formatter setDefaultOutputPattern:@"(##) #####-####"];
    [self updateProfileFields];
    [self configureFacebookLoginButton];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.loadingButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    self.changePhotoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FBTokenChanged:) name:FBSDKAccessTokenDidChangeNotification object:nil];
    
    if (self.completeProfileMode) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Olá!" message:@"Parece que esta é sua primeira vez usando o Caronaê. Por favor, complete seu perfil para continuar."];
        self.numDrivesLabel.text = @"0";
        self.numRidesLabel.text = @"0";
    }
}

- (void)configureFacebookLoginButton {
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.readPermissions = @[@"public_profile", @"user_friends"];
    [self.fbButtonView addSubview:loginButton];
    loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.fbButtonView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[loginButton]|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(loginButton)]];
    [self.fbButtonView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[loginButton]|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(loginButton)]];
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
    self.courseLabel.text = [NSString stringWithFormat:@"%@ | %@", user[@"profile"], user[@"course"]];
    
    self.joinedDateLabel.text = [self.joinedDateFormatter stringFromDate:joinedDate];
    self.numDrivesLabel.text = user[@"numDrives"] ? [NSString stringWithFormat:@"%ld", (long)[user[@"numDrives"] integerValue]] : @"-";
    self.numRidesLabel.text = user[@"numRides"] ? [NSString stringWithFormat:@"%ld", (long)[user[@"numRides"] integerValue]] : @"-";
    
    self.emailTextField.text = user[@"email"];
    [self.phoneTextField setFormattedText:user[@"phone_number"]];
    
    self.neighborhood = user[@"location"];
    if (![self.neighborhood isEqualToString:@""]) {
        [self.neighborhoodButton setTitle:self.neighborhood forState:UIControlStateNormal];
    }
    else {
        [self.neighborhoodButton setTitle:@"Bairro" forState:UIControlStateNormal];
    }
    
    self.hasCarSwitch.on = [user[@"car_owner"] isEqual:@(YES)];
    if (!self.hasCarSwitch.on) {
        _carDetailsHeightOriginal = _carDetailsHeight.constant;
        _carDetailsHeight.constant = 0;
        _carDetailsView.alpha = 0.0f;
    }
    
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

- (NSDictionary *)generateUserDictionaryFromView {
    NSDictionary *updatedUser = @{
                                  @"name": self.user[@"name"],
                                  @"profile": self.user[@"profile"],
                                  @"course": self.user[@"course"],
                                  @"phone_number": self.phoneTextField.phoneNumber,
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

- (void)saveProfile {
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
        NSLog(@"Error saving profile: %@", error.localizedDescription);
        [CaronaeAlertController presentOkAlertWithTitle:@"Erro atualizando perfil" message:@"Ocorreu um erro salvando as alterações no seu perfil."];
    }];
}

- (BOOL)userInputValid {
    NSString *email = self.emailTextField.text;
    
    if (![email isValidEmail]) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Dados incompletos" message:@"Ops! Parece que o endereço de email que você inseriu não é válido."];
        return NO;
    }
    
    NSString *phone = self.phoneTextField.phoneNumber;
    if (phone.length != 11) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Dados incompletos" message:@"Ops! Parece que o telefone que você inseriu não é válido."];
        return NO;
    }
    
    if (!self.neighborhood || [self.neighborhood isEqualToString:@""]) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Dados incompletos" message:@"Ops! Parece que você esqueceu de preencher seu bairro."];
        return NO;
    }
    
    if (self.hasCarSwitch.on && ([self.carModelTextField.text isEqualToString:@""] ||  [self.carPlateTextField.text isEqualToString:@""] ||  [self.carColorTextField.text isEqualToString:@""])) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Dados incompletos" message:@"Ops! Parece que você marcou que tem um carro mas não preencheu os dados dele."];
        return NO;
    }
    
    if (self.hasCarSwitch.on && ![self.carPlateTextField.text isValidCarPlate]) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Dados incompletos" message:@"Ops! Parece que preencheu incorretamente a placa do seu carro. Verifique se a preencheu no formato \"ABC-1234\"."];
        return NO;
    }
    
    return YES;
}

#pragma mark - Zone selection methods

- (void)hasSelectedNeighborhood:(NSString *)neighborhood inZone:(NSString *)zone {
    self.neighborhood = neighborhood;
    [self.neighborhoodButton setTitle:self.neighborhood forState:UIControlStateNormal];
}


#pragma mark - IBActions

- (IBAction)didTapSaveButton:(id)sender {
    [self.view endEditing:YES];
    
    if ([self userInputValid]) {
        [self saveProfile];
    }
}

- (IBAction)didTapCancelButton:(id)sender {
    [self.view endEditing:YES];
    
    CaronaeAlertController *alert;
    
    if (!self.completeProfileMode) {
        alert = [CaronaeAlertController alertControllerWithTitle:@"Cancelar edição do perfil?"
                                                         message:@"Quaisquer mudanças serão descartadas."
                                                  preferredStyle:SDCAlertControllerStyleAlert];
        [alert addAction:[SDCAlertAction actionWithTitle:@"Cont. editando" style:SDCAlertActionStyleCancel handler:nil]];
        [alert addAction:[SDCAlertAction actionWithTitle:@"Descartar" style:SDCAlertActionStyleDestructive handler:^(SDCAlertAction *action){
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
    }
    else {
        alert = [CaronaeAlertController alertControllerWithTitle:@"Cancelar criação do perfil?"
                                                         message:@"Você será deslogado do aplicativo e precisará entrar novamente com o token."
                                                  preferredStyle:SDCAlertControllerStyleAlert];
        [alert addAction:[SDCAlertAction actionWithTitle:@"Cont. editando" style:SDCAlertActionStyleCancel handler:nil]];
        [alert addAction:[SDCAlertAction actionWithTitle:@"Cancelar" style:SDCAlertActionStyleDestructive handler:^(SDCAlertAction *action){
            [CaronaeDefaults signOut];
        }]];
    }
    
    [alert presentWithCompletion:nil];
}

- (IBAction)didTapPhoto:(id)sender {
    // TODO: support for iOS 7
    if ([UIAlertController class]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"De onde deseja importar sua foto?" preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Usar foto do Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self importPhotoFromFacebook];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Usar foto do SIGA" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self importPhotoFromSIGA];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Remover minha foto" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Removendo foto...");
            _photoURL = nil;
            _photo.image = [UIImage imageNamed:@"Profile Picture"];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"De onde deseja importar sua foto?" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:@"Remover minha foto" otherButtonTitles:@"Usar foto do Facebook", @"Usar foto do SIGA", nil];
        [actionSheet showInView:self.view];
    }
}

- (IBAction)hasCarSwitchChanged:(UISwitch *)sender {
    [self.view endEditing:YES];
    if (sender.on) {
        [self.view layoutIfNeeded];
        _carDetailsHeight.constant = _carDetailsHeightOriginal;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
            _carDetailsView.alpha = 1.0f;
        }];
        // Scroll to bottom
        [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.contentSize.width - 1, self.scrollView.contentSize.height - 1, 1, 1) animated:YES];
    }
    else {
        [self.view layoutIfNeeded];
        _carDetailsHeightOriginal = _carDetailsHeight.constant;
        _carDetailsHeight.constant = 0;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
            _carDetailsView.alpha = 0.0f;
        }];
    }
}


#pragma mark - UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
            // Remove photo
        case 0:
            NSLog(@"Removendo foto...");
            _photoURL = nil;
            _photo.image = [UIImage imageNamed:@"Profile Picture"];
            break;
            // Import from Facebook
        case 1:
            [self importPhotoFromFacebook];
            break;
            // Import from SIGA
        case 2:
            [self importPhotoFromSIGA];
            break;
        default:
            break;
    }
    
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
    
    id fbToken;
    if (token.tokenString) {
        fbToken = token.tokenString;
    }
    else {
        fbToken = [NSNull null];
    }
    
    id fbID;
    if (notification.userInfo[FBSDKAccessTokenDidChangeUserID]) {
        if (token.userID) {
            NSLog(@"Facebook has loogged in with Facebook ID %@.", token.userID);
            fbID = token.userID;
        }
        else {
            NSLog(@"User has logged out from Facebook.");
            fbID = [NSNull null];
        }
    }
    
    [self updateUsersFacebookID:fbID token:fbToken success:^(id responseObject) {
        NSLog(@"Updated user's Facebook credentials on server.");
    } failure:^(NSError *error) {
        NSLog(@"Error updating user's Facebook credentials on server: %@", error.localizedDescription);
    } tries:3];
}

- (void)updateUsersFacebookID:(id)fbID token:(id)token success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure tries:(NSUInteger)times {
    if (times <= 0) {
        failure([NSError errorWithDomain:CaronaeErrorDomain code:3 userInfo:@{@"localizedDescription":@"Failed updating user's Facebook ID remotely."}]);
    }
    else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
        
        NSDictionary *params;
        if (fbID) {
            params = @{@"id": fbID, @"token": token};
        }
        else {
            params = @{@"token": token};
        }
        
        [manager PUT:[CaronaeAPIBaseURL stringByAppendingString:@"/user/saveFaceId"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(operation);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self updateUsersFacebookID:fbID token:token success:success failure:failure tries:times-1];
        }];
    }
}

- (void)importPhotoFromFacebook {
    if (![FBSDKAccessToken currentAccessToken]) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Conta do Facebook não autorizada." message:@"Você precisa ter feito login com sua conta do Facebook."];
        return;
    }
    
    NSLog(@"Importing profile picture from Facebook...");
    
    [SVProgressHUD show];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"me/picture?type=large&redirect=false"
                                  parameters:@{@"fields": @"url"}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
            NSDictionary *data = result[@"data"];
            _photoURL = data[@"url"];
            [_photo sd_setImageWithURL:[NSURL URLWithString:_photoURL]
                      placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                               options:SDWebImageRefreshCached
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 [SVProgressHUD dismiss];
                             }];
        }
        else {
            [SVProgressHUD dismiss];
            NSLog(@"result: %@", error.localizedDescription);
            [CaronaeAlertController presentOkAlertWithTitle:@"Erro atualizando foto" message:@"Não foi possível carregar sua foto de perfil do Facebook."];
        }
    }];
}


#pragma mark - SIGA integration

- (void)importPhotoFromSIGA {
    NSLog(@"Importing profile picture from SIGA...");
    
    [SVProgressHUD show];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:@"/user/intranetPhotoUrl"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _photoURL = responseObject[@"url"];
        [_photo sd_setImageWithURL:[NSURL URLWithString:_photoURL]
                  placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                           options:SDWebImageRefreshCached
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             [SVProgressHUD dismiss];
                         }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"result: %@", error.localizedDescription);
        [CaronaeAlertController presentOkAlertWithTitle:@"Erro atualizando foto" message:@"Não foi possível carregar sua foto de perfil do SIGA."];
    }];
}

@end
