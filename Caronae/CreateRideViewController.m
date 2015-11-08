#import "CreateRideViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface CreateRideViewController ()

@end

@implementation CreateRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.segmentedControl.layer.cornerRadius = 8.0;
    self.segmentedControl.layer.borderColor = [UIColor colorWithWhite:0.690 alpha:1.000].CGColor;
    self.segmentedControl.layer.borderWidth = 2.0f;
    self.segmentedControl.layer.masksToBounds = YES;
    
    self.notes.layer.cornerRadius = 8.0;
    self.notes.layer.borderColor = [UIColor colorWithWhite:0.902 alpha:1.000].CGColor;
    self.notes.layer.borderWidth = 2.0f;
    self.notes.textContainerInset = UIEdgeInsetsMake(10, 5, 5, 5);
    
    self.slotsLabel.text = [NSString stringWithFormat:@"%.f", self.slotsStepper.value];
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createRide:(id)sender {
    NSLog(@"Tapped create ride");
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"dd/MM/yyyy";
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    timeFormat.dateFormat = @"HH:mm";
    
    NSDictionary *ride = @{
                           @"myzone": @"Norte",
                           @"neighborhood": self.origin.text,
                           @"place": self.reference.text,
                           @"route": self.route.text,
                           @"mydate": [dateFormat stringFromDate:self.datePicker.date],
                           @"mytime": [timeFormat stringFromDate:self.datePicker.date],
                           @"slots": @((int)self.slotsStepper.value),
                           @"hub": @"A",
                           @"description": self.notes.text,
                           @"going": @(self.segmentedControl.selectedSegmentIndex == 0),
                           @"week_days": @"",
                           @"repeats_until": @""
                           };
    NSLog(@"%@", ride);
    
    NSString *userToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"][@"token"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:userToken forHTTPHeaderField:@"token"];
    [manager POST:@"http://45.55.46.90:8080/ride" parameters:ride success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response JSON: %@", responseObject);
        
        // Check if we received an array of the created rides
        if ([responseObject isKindOfClass:NSArray.class]) {
            NSArray *createdRides = responseObject;
            if (createdRides.count > 0) {
                NSLog(@"%lu rides created.", (unsigned long)createdRides.count);
            }
            else {
                NSLog(@"No rides created.");
            }
        }
        else {
            NSLog(@"Unexpected JSON format (not an array).");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"body: %@", operation.responseString);
    }];

}

- (IBAction)slotsStepperChanged:(UIStepper *)sender {
    self.slotsLabel.text = [NSString stringWithFormat:@"%.f", sender.value];
}

- (IBAction)routineSwitchChanged:(UISwitch *)sender {
    if (sender.on) {
        self.arrivalView.hidden = YES;
        self.routinePatternView.hidden = NO;
    }
    else {
        self.arrivalView.hidden = NO;
        self.routinePatternView.hidden = YES;
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
