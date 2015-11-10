#import "CreateRideViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface CreateRideViewController ()

@end

@implementation CreateRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.weekDays = [NSMutableArray arrayWithCapacity:7];
    self.routineDurationMonths = 2;
    
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
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"dd/MM/yyyy";
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    timeFormat.dateFormat = @"HH:mm";
    NSString *weekDaysString = [[self.weekDays sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] componentsJoinedByString:@","];
    BOOL isRoutine = self.routineSwitch.on;
    NSDate *eventDate = self.datePicker.date;

    // Calculate final date for event based on the selected duration
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = self.routineDurationMonths;
    NSDate *repeatsUntilDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:eventDate options:0];
    
    NSDictionary *ride = @{
                           @"myzone": @"Norte",
                           @"neighborhood": self.origin.text,
                           @"place": self.reference.text,
                           @"route": self.route.text,
                           @"mydate": [dateFormat stringFromDate:eventDate],
                           @"mytime": [timeFormat stringFromDate:eventDate],
                           @"slots": @((int)self.slotsStepper.value),
                           @"hub": @"A",
                           @"description": self.notes.text,
                           @"going": @(self.segmentedControl.selectedSegmentIndex == 0),
                           @"week_days": isRoutine ? weekDaysString : @"",
                           @"repeats_until": isRoutine ? [dateFormat stringFromDate:repeatsUntilDate] : @""
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


#pragma mark - Routine selection buttons

- (IBAction)routineMondayButtonTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.weekDays addObject:@"1"];
    }
    else {
        [self.weekDays removeObject:@"1"];
    }
}

- (IBAction)routineTuesdayButtonTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.weekDays addObject:@"2"];
    }
    else {
        [self.weekDays removeObject:@"2"];
    }
}

- (IBAction)routineWednesdayButtonTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.weekDays addObject:@"3"];
    }
    else {
        [self.weekDays removeObject:@"3"];
    }
}

- (IBAction)routineThursdayButtonTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.weekDays addObject:@"4"];
    }
    else {
        [self.weekDays removeObject:@"4"];
    }
}

- (IBAction)routineFridayButtonTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.weekDays addObject:@"5"];
    }
    else {
        [self.weekDays removeObject:@"5"];
    }
}

- (IBAction)routineSaturdayButtonTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.weekDays addObject:@"6"];
    }
    else {
        [self.weekDays removeObject:@"6"];
    }
}

- (IBAction)routineSundayButtonTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.weekDays addObject:@"7"];
    }
    else {
        [self.weekDays removeObject:@"7"];
    }
}

- (IBAction)routineDurationButtonTapped:(UIButton *)sender {
    sender.selected = YES;
    if (sender == self.routineDuration2MonthsButton) {
        self.routineDurationMonths = 2;
        self.routineDuration3MonthsButton.selected = NO;
        self.routineDuration4MonthsButton.selected = NO;
    }
    else if (sender == self.routineDuration3MonthsButton) {
        self.routineDurationMonths = 3;
        self.routineDuration2MonthsButton.selected = NO;
        self.routineDuration4MonthsButton.selected = NO;
    }
    else if (sender == self.routineDuration4MonthsButton) {
        self.routineDurationMonths = 4;
        self.routineDuration2MonthsButton.selected = NO;
        self.routineDuration3MonthsButton.selected = NO;
    }
}    

@end
