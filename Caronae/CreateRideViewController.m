#import "CaronaeDefaults.h"
#import "CreateRideViewController.h"
#import "NSDate+nextHour.h"
#import <AFNetworking/AFNetworking.h>
#import <ActionSheetDatePicker.h>
#import <ActionSheetStringPicker.h>

@interface CreateRideViewController () <UITextViewDelegate>

@property (nonatomic) CGFloat routinePatternHeightOriginal;
@property (nonatomic) NSString *notesPlaceholder;
@property (nonatomic) UIColor *notesTextColor;
@property (nonatomic) NSDateFormatter *arrivalDateLabelFormatter;
@property (nonatomic) NSString *selectedHub;
@property (nonatomic) NSArray *hubs;
@end

@implementation CreateRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hubs = [CaronaeDefaults defaults].centers;
    self.selectedHub = self.hubs[0];
    
    self.rideDate = [NSDate nextHour];
    self.weekDays = [NSMutableArray arrayWithCapacity:7];
    self.routineDurationMonths = 2;
    
    self.arrivalDateLabelFormatter = [[NSDateFormatter alloc] init];
    self.arrivalDateLabelFormatter.dateFormat = @"dd/MM/yyyy HH:mm";
    [self.arrivalTimeButton setTitle:[self.arrivalDateLabelFormatter stringFromDate:self.rideDate] forState:UIControlStateNormal];
    
    self.segmentedControl.layer.cornerRadius = 8.0;
    self.segmentedControl.layer.borderColor = [UIColor colorWithWhite:0.690 alpha:1.000].CGColor;
    self.segmentedControl.layer.borderWidth = 2.0f;
    self.segmentedControl.layer.masksToBounds = YES;
    
    self.notes.layer.cornerRadius = 8.0;
    self.notes.layer.borderColor = [UIColor colorWithWhite:0.902 alpha:1.000].CGColor;
    self.notes.layer.borderWidth = 2.0f;
    self.notes.textContainerInset = UIEdgeInsetsMake(10, 5, 5, 5);
    self.notes.delegate = self;
    self.notesPlaceholder = self.notes.text;
    self.notesTextColor = self.notes.textColor;
    
    self.slotsLabel.text = [NSString stringWithFormat:@"%.f", self.slotsStepper.value];
    
    // Dismiss keyboard when tapping the view
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary *)generateRideDictionaryFromView {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"dd/MM/yyyy";
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    timeFormat.dateFormat = @"HH:mm";
    NSString *weekDaysString = [[self.weekDays sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] componentsJoinedByString:@","];
    NSString *description = [self.notes.text isEqualToString:_notesPlaceholder] ? @"" : self.notes.text;
    BOOL isRoutine = self.routineSwitch.on;
    BOOL going = (self.segmentedControl.selectedSegmentIndex == 0);
    
    // Calculate final date for event based on the selected duration
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = self.routineDurationMonths;
    NSDate *repeatsUntilDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self.rideDate options:0];
    
    NSDictionary *ride = @{
                           @"myzone": @"Norte",
                           @"neighborhood": self.origin.text,
                           @"place": self.reference.text,
                           @"route": self.route.text,
                           @"mydate": [dateFormat stringFromDate:self.rideDate],
                           @"mytime": [timeFormat stringFromDate:self.rideDate],
                           @"week_days": isRoutine ? weekDaysString : [NSNull null],
                           @"repeats_until": isRoutine ? [dateFormat stringFromDate:repeatsUntilDate] : [NSNull null],
                           @"slots": @((int)self.slotsStepper.value),
                           @"hub": self.selectedHub,
                           @"description": description,
                           @"going": @(going)
                           };
    return ride;
}

+ (NSArray *)parseCreateRidesFromResponse:(id)responseObject withError:(NSError *__autoreleasing *)err {
    // Check if we received an array of the created rides
    if ([responseObject isKindOfClass:NSArray.class]) {
        
        NSArray *createdRides = responseObject;
        if (createdRides.count == 0) {
            if (err) {
                NSDictionary *errorInfo = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"No rides were created.", nil)
                                           };
                *err = [NSError errorWithDomain:CaronaeErrorDomain code:CaronaeErrorNoRidesCreated userInfo:errorInfo];
            }
        }
        else {
            return createdRides;
        }
    }
    else {
        if (err) {
            NSDictionary *errorInfo = @{
                                        NSLocalizedDescriptionKey: NSLocalizedString(@"Unexpected server response.", nil)
                                        };
            *err = [NSError errorWithDomain:CaronaeErrorDomain code:CaronaeErrorInvalidResponse userInfo:errorInfo];
        }
    }
    
    return nil;
}

- (IBAction)createRide:(id)sender {
    NSDictionary *ride;
    ride = [self generateRideDictionaryFromView];
    NSLog(@"%@", ride);
    
    NSString *userToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:userToken forHTTPHeaderField:@"token"];
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/ride"] parameters:ride success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response JSON: %@", responseObject);
        NSError *responseError;
        NSArray *createdRides = [CreateRideViewController parseCreateRidesFromResponse:responseObject withError:&responseError];
        if (responseError) {
            NSLog(@"Response error: %@", responseError.description);
        }
        else {
            NSLog(@"%lu rides created.", (unsigned long)createdRides.count);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
//        NSLog(@"body: %@", operation.responseString);
    }];

}

- (IBAction)slotsStepperChanged:(UIStepper *)sender {
    self.slotsLabel.text = [NSString stringWithFormat:@"%.f", sender.value];
}


#pragma mark - Routine selection buttons

/**
 *  Show or hide the routine pattern fields if the 'generate routines' switch changes.
 *
 *  @param sender 'Generate routines' UISwitch
 */
- (IBAction)routineSwitchChanged:(UISwitch *)sender {
    if (sender.on) {
        [self.view layoutIfNeeded];
        _routinePatternHeight.constant = _routinePatternHeightOriginal;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
            self.routinePatternView.alpha = 1.0f;
        }];
    }
    else {
        [self.view layoutIfNeeded];
        _routinePatternHeightOriginal = _routinePatternHeight.constant;
        _routinePatternHeight.constant = 0;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
            self.routinePatternView.alpha = 0.0f;
        }];
    }
}

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

- (IBAction)routineSelectDateTapped:(id)sender {
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Chegada ao destino" datePickerMode:UIDatePickerModeDateAndTime selectedDate:self.rideDate target:self action:@selector(timeWasSelected:element:) origin:sender];
    [datePicker showActionSheetPicker];
}

- (void)timeWasSelected:(NSDate *)selectedTime element:(id)element {
    self.rideDate = selectedTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    [self.arrivalTimeButton setTitle:[dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
}

- (IBAction)directionChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.hubs = [CaronaeDefaults defaults].centers;
    }
    else {
        self.hubs = [CaronaeDefaults defaults].hubs;
    }
    self.selectedHub = self.hubs[0];
    [self.center setTitle:self.selectedHub forState:UIControlStateNormal];
}

- (IBAction)selectCenterTapped:(id)sender {
    [ActionSheetStringPicker showPickerWithTitle:@"Selecione um centro"
                                            rows:self.hubs
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           self.selectedHub = selectedValue;
                                           [self.center setTitle:selectedValue forState:UIControlStateNormal];
                                       }
                                     cancelBlock:nil origin:sender];
}

#pragma mark - UITextView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:_notesPlaceholder]) {
        textView.text = @"";
        textView.textColor = _notesTextColor;
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = _notesPlaceholder;
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}

@end
