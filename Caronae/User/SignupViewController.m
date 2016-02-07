#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "CaronaeAlertController.h"
#import "SignupViewController.h"

@interface SignupViewController ()
@property (weak, nonatomic) IBOutlet UILabel *baseAPILabel;
@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *tokenTextField;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseAPILabel.text = [NSString stringWithFormat:@"API base: %@", CaronaeAPIBaseURL];
}

- (void)signUp {
    NSString *idUFRJ = self.idTextField.text;
    NSString *token = self.tokenTextField.text;
    
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:[NSString stringWithFormat:@"/user/signup/intranet/%@/%@", idUFRJ, token]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        
        // Check if the authentication was ok if we received an user object
        if (responseObject[@"id"]) {
            NSString *msg = [NSString stringWithFormat:@"Use o token %@ para autenticar.", token];
            [CaronaeAlertController presentOkAlertWithTitle:@"Usuário criado." message:msg handler:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        else {
            NSLog(@"Error authenticating");
            self.createButton.enabled = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error creating user: %@", error.localizedDescription);
        
        NSString *errorMsg;
        if (operation.responseObject[@"error"]) {
            errorMsg = operation.responseObject[@"error"];
        }
        else {
            errorMsg = [NSString stringWithFormat:@"Ocorreu um erro desconhecido ou a conexão falhou. (%@)", error.localizedDescription];
        }
        
        [CaronaeAlertController presentOkAlertWithTitle:@"Não foi possível criar o usuário." message:errorMsg];
        self.createButton.enabled = YES;
    }];

}


#pragma mark - IBActions

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapCreateButton:(id)sender {
    if (![self.idTextField.text isEqualToString:@""] && ![self.tokenTextField.text isEqualToString:@""]) {
        [self signUp];
    }
    else {
        [CaronaeAlertController presentOkAlertWithTitle:@"Não foi possível criar o usuário." message:@"Preencha todos os campos."];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
