#import <AFNetworking/AFNetworking.h>
#import "CaronaeDefaults.h"
#import "TokenViewController.h"

@interface TokenViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tokenTextField;
@property (weak, nonatomic) IBOutlet UIButton *authenticateButton;
@end

@implementation TokenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)didTapAuthenticateButton:(UIButton *)sender {
    sender.enabled = NO;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *userToken = self.tokenTextField.text;
    NSDictionary *parameters = @{@"token": userToken};
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/user/login"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Check if the authentication was ok if we received an user object
        if (responseObject[@"user"]) {            
            // Convert NSNull properties to empty strings
            NSDictionary *userProfile = [self dictionaryWithoutNulls:responseObject[@"user"]];
            [[NSUserDefaults standardUserDefaults] setObject:userProfile forKey:@"user"];
            
            NSArray *rides = responseObject[@"rides"];
            NSMutableArray *filteredRides = [NSMutableArray arrayWithCapacity:rides.count];
            for (id rideDictionary in rides) {
                [filteredRides addObject:[self dictionaryWithoutNulls:rideDictionary]];
            }
            [[NSUserDefaults standardUserDefaults] setObject:filteredRides forKey:@"userCreatedRides"];
            
            [[NSUserDefaults standardUserDefaults] setObject:userToken forKey:@"token"];
            [self performSegueWithIdentifier:@"tokenValidated" sender:self];
        }
        else {
            NSLog(@"Error authenticating");
            sender.enabled = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
        sender.enabled = YES;
    }];
}

- (NSDictionary *)dictionaryWithoutNulls:(NSDictionary *)dictionary {
    NSMutableDictionary *new = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    for (id key in new.allKeys) {
        if ([new[key] isKindOfClass:[NSNull class]]) {
            new[key] = @"";
        }
    }
    return new;
}

@end
