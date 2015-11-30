#import <AFNetworking/AFNetworking.h>
#import "NSDictionary+dictionaryWithoutNulls.h"
#import "TokenViewController.h"

@interface TokenViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tokenTextField;
@property (weak, nonatomic) IBOutlet UIButton *authenticateButton;
@end

@implementation TokenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)authenticate {
    self.authButton.enabled = NO;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *userToken = self.tokenTextField.text;
    NSDictionary *parameters = @{@"token": userToken};
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/user/login"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
            
            [self.authTextField resignFirstResponder];
            [self performSegueWithIdentifier:@"tokenValidated" sender:self];
        }
        else {
            NSLog(@"Error authenticating");
            self.authButton.enabled = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
        self.authButton.enabled = YES;
    }];

}

- (IBAction)didTapAuthenticateButton:(UIButton *)sender {
    [self authenticate];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.authTextField) {
        [self authenticate];
        return NO;
    }
    
    return YES;
}


@end
