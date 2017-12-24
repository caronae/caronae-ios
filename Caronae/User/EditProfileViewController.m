@import FBSDKCoreKit;
@import FBSDKLoginKit;
@import SVProgressHUD;
#import "CaronaeAlertController.h"
#import "CaronaeTextField.h"
#import "CaronaePhoneTextField.h"
#import "NSString+validation.h"
#import "EditProfileViewController.h"
#import "UIImageView+crn_setImageWithURL.h"
#import "Caronae-Swift.h"

@class Constants;

@interface EditProfileViewController () <NeighborhoodSelectionDelegate, UIActionSheetDelegate, UITextFieldDelegate>
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
    [self.phoneTextField.formatter setDefaultOutputPattern:[Constants Caronae8PhoneNumberPatternObjc]];
    [self.phoneTextField.formatter addOutputPattern:[Constants Caronae9PhoneNumberPatternObjc] forRegExp:@"[0-9]{12}\\d*$"];
    self.phoneTextField.delegate = self;
    [self updateProfileFields];
    [self configureFacebookLoginButton];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.loadingButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    self.changePhotoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    if (self.completeProfileMode) {
        self.numDrivesLabel.text = @"0";
        self.numRidesLabel.text = @"0";
        self.title = @"Cadastro";
    }
}

- (void)configureFacebookLoginButton {
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    [loginButton removeConstraints:loginButton.constraints];
    loginButton.readPermissions = @[@"public_profile", @"user_friends"];
    [self.fbButtonView addSubview:loginButton];
    loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.fbButtonView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[loginButton]|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(loginButton)]];
    [self.fbButtonView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[loginButton]|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(loginButton)]];
}

- (void)updateProfileFields {
    User *user = UserService.instance.user;
    self.user = user;
    
    self.joinedDateFormatter = [[NSDateFormatter alloc] init];
    self.joinedDateFormatter.dateFormat = @"MM/yyyy";
    
    self.nameLabel.text = user.name;
    self.courseLabel.text = user.course.length > 0 ? [NSString stringWithFormat:@"%@ | %@", user.profile, user.course] : user.profile;
    
    self.joinedDateLabel.text = [self.joinedDateFormatter stringFromDate:user.createdAt];
    self.numDrivesLabel.text = user.numDrives > -1 ? [NSString stringWithFormat:@"%ld", (long)user.numDrives] : @"-";
    self.numRidesLabel.text = user.numRides > -1 ? [NSString stringWithFormat:@"%ld", (long)user.numRides] : @"-";
    
    self.emailTextField.text = user.email;
    [self.phoneTextField setFormattedText:user.phoneNumber];
    
    self.neighborhood = user.location;
    if (![self.neighborhood isEqualToString:@""]) {
        [self.neighborhoodButton setTitle:self.neighborhood forState:UIControlStateNormal];
    }
    else {
        [self.neighborhoodButton setTitle:@"Bairro" forState:UIControlStateNormal];
    }
    
    self.hasCarSwitch.on = user.carOwner;
    if (!self.hasCarSwitch.on) {
        _carDetailsHeightOriginal = _carDetailsHeight.constant;
        _carDetailsHeight.constant = 0;
        _carDetailsView.alpha = 0.0f;
    }
    
    self.carPlateTextField.text = user.carPlate;
    self.carModelTextField.text = user.carModel;
    self.carColorTextField.text = user.carColor;
    
    self.photoURL = user.profilePictureURL;
    if (self.photoURL.length > 0) {
        [self.photo crn_setImageWithURL:[NSURL URLWithString:self.photoURL]];
    }
}

- (User *)generateUserFromView {
    User *updatedUser = [[User alloc] init];
    updatedUser.name = self.user.name;
    updatedUser.profile = self.user.profile;
    updatedUser.course = self.user.course;
    updatedUser.phoneNumber = self.phoneTextField.phoneNumber;
    updatedUser.email = self.emailTextField.text;
    updatedUser.carOwner = self.hasCarSwitch.on;
    updatedUser.carModel = self.carModelTextField.text;
    updatedUser.carPlate = self.carPlateTextField.text;
    updatedUser.carColor = self.carColorTextField.text;
    updatedUser.location = self.neighborhood;
    updatedUser.profilePictureURL = _photoURL;

    return updatedUser;
}

- (void)saveProfile {
    User *updatedUser = [self generateUserFromView];
    [self showLoadingHUD:YES];
    
    __weak typeof(self) weakSelf = self;
    [UserService.instance updateUser:updatedUser success:^{
        [weakSelf showLoadingHUD:NO];
        NSLog(@"User updated.");
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    } error:^(NSError * _Nonnull error) {
        [weakSelf showLoadingHUD:NO];
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
    if (phone.length != 12 && phone.length != 11) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Dados incompletos" message:@"Ops! Parece que o telefone que você inseriu não é válido. Ele deve estar no formato (0XX) XXXXX-XXXX."];
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

- (void)hasSelectedWithNeighborhoods:(NSArray<NSString *> *)neighborhoods inZone:(NSString *)zone {
    self.neighborhood = [neighborhoods firstObject];
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
        alert = [CaronaeAlertController alertControllerWithTitle:@"Cancelar cadastro?"
                                                         message:@"Você será deslogado do aplicativo e precisará entrar novamente com sua chave."
                                                  preferredStyle:SDCAlertControllerStyleAlert];
        [alert addAction:[SDCAlertAction actionWithTitle:@"Cont. editando" style:SDCAlertActionStyleCancel handler:nil]];
        [alert addAction:[SDCAlertAction actionWithTitle:@"Sair" style:SDCAlertActionStyleDestructive handler:^(SDCAlertAction *action){
            [UserService.instance signOut];
        }]];
    }
    
    [alert presentWithCompletion:nil];
}

- (IBAction)didTapPhoto:(id)sender {
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

- (IBAction)selectNeighborhoodTapped:(id)sender {
    NeighborhoodSelectionViewController *selectionVC = [[NeighborhoodSelectionViewController alloc] initWithSelectionType:SelectionTypeOneSelection];
    [selectionVC setDelegate:self];
    [self.navigationController pushViewController:selectionVC animated:YES];
}


#pragma mark - UITextField methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // Automatically add prefix
    if (textField == self.phoneTextField && self.phoneTextField.phoneNumber.length == 0) {
        [self.phoneTextField setFormattedText:@"021"];
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

- (void)importPhotoFromFacebook {
    if (![FBSDKAccessToken currentAccessToken]) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Conta do Facebook não autorizada." message:@"Você precisa ter feito login com sua conta do Facebook."];
        return;
    }
    
    NSLog(@"Importing profile picture from Facebook...");
    
    [SVProgressHUD show];
    [UserService.instance getPhotoFromFacebookWithSuccess:^(NSString * _Nonnull url) {
        _photoURL = url;
        [_photo crn_setImageWithURL:[NSURL URLWithString:_photoURL] completed:^{
            [SVProgressHUD dismiss];
        }];

    } error:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error loading photo: %@", error.localizedDescription);
        [CaronaeAlertController presentOkAlertWithTitle:@"Erro atualizando foto" message:@"Não foi possível carregar sua foto de perfil do Facebook."];
    }];
}

@end
