#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "NSDictionary+dictionaryWithoutNulls.h"
#import "CaronaeAlertController.h"
#import "TokenViewController.h"

@interface TokenViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tokenTextField;
@property (weak, nonatomic) IBOutlet UIButton *authenticateButton;
@end

@implementation TokenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _authButton.enabled = NO;
}

- (void)authenticate {
    _authButton.enabled = NO;
    [_authTextField resignFirstResponder];
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *userToken = _tokenTextField.text;
    NSDictionary *parameters = @{@"token": userToken};
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/user/login"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        
        // Check if the authentication was ok if we received an user object
        if (responseObject[@"user"]) {
            // Save user's profile
            NSDictionary *userProfile = [responseObject[@"user"] dictionaryWithoutNulls];
            [CaronaeDefaults defaults].user = userProfile;
            
            // Save user's created rides
            NSArray *rides = responseObject[@"rides"];
            NSMutableArray *filteredRides = [NSMutableArray arrayWithCapacity:rides.count];
            for (id rideDictionary in rides) {
                [filteredRides addObject:[rideDictionary dictionaryWithoutNulls]];
            }
            [[NSUserDefaults standardUserDefaults] setObject:filteredRides forKey:@"userCreatedRides"];
            
            // Save user's token
            [CaronaeDefaults defaults].userToken = userToken;
            
            [self performSegueWithIdentifier:@"tokenValidated" sender:self];
        }
        else {
            NSLog(@"Error authenticating");
            _authButton.enabled = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error: %@", error.localizedDescription);
        
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

- (IBAction)didTapAuthenticateButton:(UIButton *)sender {
    [self authenticate];
}


#pragma mark Text field methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _authTextField) {
        [self authenticate];
        return NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([text isEqualToString:@""]) {
        _authButton.enabled = NO;
    }
    else {
        _authButton.enabled = YES;
    }
    
    return YES;
}


@end
