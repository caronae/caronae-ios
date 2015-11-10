#import "CaronaeConstants.h"
#import "TokenViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface TokenViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tokenTextField;
@property (weak, nonatomic) IBOutlet UIButton *authenticateButton;
@end

@implementation TokenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)didTapAuthenticateButton:(id)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"token": self.tokenTextField.text};
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/auth"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        // Check if the authentication was ok if we received an user object
        if (responseObject[@"user"]) {
            // Convert NSNull properties to empty strings
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithDictionary:responseObject[@"user"]];
            for (id key in userProfile.allKeys) {
                if ([userProfile[key] isKindOfClass:[NSNull class]]) {
                    userProfile[key] = @"";
                }
            }
            [[NSUserDefaults standardUserDefaults] setObject:userProfile forKey:@"user"];
            [self performSegueWithIdentifier:@"tokenValidated" sender:self];
        }
        else {
            NSLog(@"Error authenticating");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
