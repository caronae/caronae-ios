#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "CaronaeAlertController.h"
#import "EditProfileViewController.h"
#import "NSDictionary+dictionaryWithoutNulls.h"
#import "TokenViewController.h"

@interface TokenViewController () <UITextFieldDelegate>

@end

@implementation TokenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _authButton.enabled = NO;
    _tokenTextField.delegate = self;
    _idTextField.delegate = self;
}

- (void)authenticate {
    _authButton.enabled = NO;
    [self.view endEditing:YES];
    [SVProgressHUD show];
    
    NSString *userToken = _tokenTextField.text;
    NSString *idUFRJ = _idTextField.text;
    NSDictionary *params = @{ @"id_ufrj": idUFRJ,
                                  @"token": userToken };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/user/login"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                [CaronaeAlertController presentOkAlertWithTitle:@"Não foi possível autenticar." message:@"Ocorreu um erro carregando seu perfil."];
                _authButton.enabled = YES;
                return;
            }
            
            [CaronaeDefaults signIn:user token:userToken rides:filteredRides];
            
            [CaronaeDefaults registerForNotifications];
            
            [self performSegueWithIdentifier:@"ViewHome" sender:self];
        }
        else {
            NSLog(@"Error authenticating");
            _authButton.enabled = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error trying to authenticate: %@", error.localizedDescription);
        
        NSString *errorMsg;
        if (operation.response.statusCode == 403) {
            errorMsg = @"Token não autorizado. Verifique se o mesmo foi digitado corretamente e tente de novo.";
        }
        else {
            errorMsg = [NSString stringWithFormat:@"Ocorreu um erro autenticando com o servidor do Caronaê. Tente novamente.\n(%@)", error.localizedDescription];
        }
        
        [CaronaeAlertController presentOkAlertWithTitle:@"Não foi possível autenticar." message:errorMsg];
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
    [self authenticate];
}


#pragma mark Text field methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _tokenTextField) {
        [self authenticate];
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
