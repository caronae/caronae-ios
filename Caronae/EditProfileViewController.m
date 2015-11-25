#import <AFNetworking/AFNetworking.h>
#import "CaronaeDefaults.h"
#import "EditProfileViewController.h"

@interface EditProfileViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic) NSDateFormatter *joinedDateFormatter;
@property (nonatomic) UIBarButtonItem *loadingButton;
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateProfileFields];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.loadingButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (IBAction)didTapCancelButton:(id)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateProfileFields {
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
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
    
    self.zoneTextField.text = @"";
    self.neighborhoodTextField.text = user[@"location"];
    
    self.hasCarSwitch.on = [user[@"car_owner"] isEqual:@(YES)];
    
    self.carPlateTextField.text = user[@"car_plate"];
    self.carModelTextField.text = user[@"car_model"];
    self.carColorTextField.text = user[@"car_color"];
}

- (IBAction)didTapSaveButton:(id)sender {
    NSDictionary *updatedUser = [self generateUserDictionaryFromView];
    NSString *userToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:userToken forHTTPHeaderField:@"token"];
    
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
        self.user = newUpdatedUser;
        
        [[NSUserDefaults standardUserDefaults] setObject:newUpdatedUser forKey:@"user"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showLoadingHUD:NO];
        NSLog(@"Error: %@", error.description);
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
                                  @"location": self.neighborhoodTextField.text
                                  };
    
    return updatedUser;
}

- (void)showLoadingHUD:(BOOL)loading {
    if (!loading) {
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = self.loadingButton;
    }
}

@end
