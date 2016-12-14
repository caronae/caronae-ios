#import <SafariServices/SafariServices.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "AppDelegate.h"
#import "CaronaeAlertController.h"
#import "EditProfileViewController.h"
#import "NSDictionary+dictionaryWithoutNulls.h"
#import "TokenViewController.h"
#import "Caronae-Swift.h"

@interface TokenViewController () <UITextFieldDelegate, CaronaeSignInDelegate>

@end

@implementation TokenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _authButton.enabled = NO;
    _tokenTextField.delegate = self;
    _idTextField.delegate = self;
    
    UITapGestureRecognizer *welcomeTextTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapWelcomeText:)];
    [_welcomeLabel addGestureRecognizer:welcomeTextTapRecognizer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_createUserButton removeFromSuperview];
    });
}

- (void)authenticateWithUser:(NSString *)user token:(NSString *)token {
    _authButton.enabled = NO;
    [self.view endEditing:YES];
    [SVProgressHUD show];
    
    NSDictionary *params = @{ @"id_ufrj": user,
                              @"token": token };
    [CaronaeAPIHTTPSessionManager.instance POST:@"/user/login" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [SVProgressHUD dismiss];
        
        // Check if the authentication was ok if we received an user object
        if (responseObject[@"user"]) {
            // Save user's created rides
            NSArray *rides = responseObject[@"rides"];
            NSMutableArray *filteredRides = [NSMutableArray arrayWithCapacity:rides.count];
            for (id rideDictionary in rides) {
                [filteredRides addObject:[rideDictionary dictionaryWithoutNulls]];
            }
            
            NSError *error;
            User *user = [MTLJSONAdapter modelOfClass:User.class fromJSONDictionary:responseObject[@"user"] error:&error];
            if (error) {
                [CaronaeAlertController presentOkAlertWithTitle:@"Não foi possível autenticar" message:@"Ocorreu um erro carregando seu perfil."];
                _authButton.enabled = YES;
                return;
            }
            
            [[UserController sharedInstance] setUser:user token:token rides:filteredRides];
            
            AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            [appDelegate registerForNotifications];
            
            [self performSegueWithIdentifier:@"ViewHome" sender:self];
        }
        else {
            NSLog(@"Error authenticating");
            _authButton.enabled = YES;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error trying to authenticate: %@", error.localizedDescription);
        
        NSString *errorMsg;
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
        if (response.statusCode == 403) {
            errorMsg = @"Chave não autorizada. Verifique se a mesma foi digitada corretamente e tente de novo.";
        }
        else {
            errorMsg = [NSString stringWithFormat:@"Ocorreu um erro autenticando com o servidor do Caronaê. Tente novamente.\n(%@)", error.localizedDescription];
        }
        
        [CaronaeAlertController presentOkAlertWithTitle:@"Não foi possível autenticar" message:errorMsg];
        _authButton.enabled = YES;
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CompleteProfile"]) {
        UINavigationController *editProfileNavController = segue.destinationViewController;
        EditProfileViewController *vc = editProfileNavController.viewControllers.firstObject;
        vc.completeProfileMode = YES;
    }
}

#pragma mark - IBActions

- (IBAction)didTapAuthenticateButton:(UIButton *)sender {
    NSString *userToken = _tokenTextField.text;
    NSString *idUFRJ = _idTextField.text;
    [self authenticateWithUser:idUFRJ token:userToken];
}

- (void)didTapWelcomeText:(id)sender {
    [CaronaeSignInViewController presentFromViewController:self delegate:self];
}


#pragma mark - Sign in delegate

- (void)caronaeDidSignInWithSuccessWithUser:(NSString *)user token:(NSString *)token {
    [self authenticateWithUser:user token:token];
}

- (void)caronaeSignInFailed {
    NSLog(@"Authentication failed");
}

#pragma mark Text field methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _tokenTextField) {
        NSString *userToken = _tokenTextField.text;
        NSString *idUFRJ = _idTextField.text;
        [self authenticateWithUser:idUFRJ token:userToken];
        return NO;
    }
    else if (textField == _idTextField && _idTextField.hasText) {
        [_tokenTextField becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == _idTextField) {
        _authButton.enabled = ![text isEqualToString:@""] && _tokenTextField.hasText;
    }
    else if (textField == _tokenTextField) {
        _authButton.enabled = ![text isEqualToString:@""] && _idTextField.hasText;
    }
    
    return YES;
}


@end
