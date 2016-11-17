#import <ActionSheetDatePicker.h>
#import <ActionSheetStringPicker.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "CaronaeAlertController.h"
#import "CreateRideViewController.h"
#import "NSDate+nextHour.h"
#import "ZoneSelectionViewController.h"
#import "Caronae-Swift.h"

@interface CreateRideViewController () <UITextViewDelegate, ZoneSelectionDelegate>

@property (nonatomic) CGFloat routinePatternHeightOriginal;
@property (nonatomic) NSString *notesPlaceholder;
@property (nonatomic) UIColor *notesTextColor;
@property (nonatomic) NSDateFormatter *arrivalDateLabelFormatter;
@property (nonatomic) NSArray *hubs;
@end

@implementation CreateRideViewController

- (void)viewDidLoad {
    if (!self.delegate) {
        NSLog(@"WARNING: No delegate for CreateRideViewController");
    }
    
    [super viewDidLoad];
    
    [self checkIfUserHasCar];
    
    self.hubs = [CaronaeConstants defaults].centers;
    self.selectedHub = self.hubs.firstObject;
    
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
    
    NSDictionary *lastRideLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastOfferedRideLocation"];
    if (lastRideLocation) {
        self.zone = lastRideLocation[@"zone"];
        self.neighborhood = lastRideLocation[@"neighborhood"];
        if (self.neighborhood) {
            [self.neighborhoodButton setTitle:self.neighborhood forState:UIControlStateNormal];
        }
        if (lastRideLocation[@"place"]) self.reference.text = lastRideLocation[@"place"];
        if (lastRideLocation[@"route"]) self.route.text = lastRideLocation[@"route"];
        if (lastRideLocation[@"hubGoing"]) {
            self.selectedHub = lastRideLocation[@"hubGoing"];
            [self.center setTitle:self.selectedHub forState:UIControlStateNormal];
        }
        if (lastRideLocation[@"description"]) self.notes.text = lastRideLocation[@"description"];
    }
}

- (void)checkIfUserHasCar {
    if (![UserController sharedInstance].user.carOwner) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Você possui carro?" message:@"Parece que você marcou no seu perfil que não possui um carro.\n\nPara criar uma carona, preencha os dados do seu carro no seu perfil." handler:^{
            [self goBack:nil];
        }];
    }
}

- (IBAction)goBack:(id)sender {
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary *)generateRideDictionaryFromView {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"dd/MM/yyyy";
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    timeFormat.dateFormat = @"HH:mm:ss";
    NSString *weekDaysString = [[self.weekDays sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] componentsJoinedByString:@","];
    NSString *description = [self.notes.text isEqualToString:_notesPlaceholder] ? @"" : self.notes.text;
    BOOL isRoutine = self.routineSwitch.on;
    BOOL going = (self.segmentedControl.selectedSegmentIndex == 0);
    
    // Calculate final date for event based on the selected duration
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = self.routineDurationMonths;
    NSDate *repeatsUntilDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self.rideDate options:0];
    
    NSDictionary *ride = @{
                           @"myzone": self.zone,
                           @"neighborhood": self.neighborhood,
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

- (void)savePresetLocationZone:(NSString *)zone neighborhood:(NSString *)neighborhood place:(NSString *)place route:(NSString *)route hub:(NSString *)hub description:(NSString *)description going:(NSNumber *)going {
    NSDictionary *location = [NSDictionary dictionary];
    NSDictionary *lastRideLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastOfferedRideLocation"];
    if (lastRideLocation) {
        location = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastOfferedRideLocation"];
    }
    if ([going boolValue]) {
        NSString *hubGoing = hub;
        NSDictionary *newLocation = NSDictionaryOfVariableBindings(zone, neighborhood, place, route, hubGoing, description);
        location = [location mtl_dictionaryByAddingEntriesFromDictionary:newLocation];
    } else {
        NSString *hubReturning = hub;
        NSDictionary *newLocation = NSDictionaryOfVariableBindings(zone, neighborhood, place, route, hubReturning, description);
        location = [location mtl_dictionaryByAddingEntriesFromDictionary:newLocation];
    }
    [[NSUserDefaults standardUserDefaults] setObject:location forKey:@"lastOfferedRideLocation"];
}

- (void)createRide:(NSDictionary *)ride {
    [SVProgressHUD show];
    self.createRideButton.enabled = NO;
    
    [CaronaeAPIHTTPSessionManager.instance POST:@"/ride" parameters:ride success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [SVProgressHUD dismiss];
        NSError *error;
        NSArray<Ride *> *rides = [MTLJSONAdapter modelsOfClass:Ride.class fromJSONArray:responseObject error:&error];
        if (error) {
            NSLog(@"Error parsing my rides. %@", error.localizedDescription);
            self.createRideButton.enabled = YES;
            [CaronaeAlertController presentOkAlertWithTitle:@"Não foi possível criar a carona." message:error.localizedDescription];
            return;
        }
        
        [self.delegate didCreateRides:rides];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        self.createRideButton.enabled = YES;
        
        NSLog(@"Error creating ride: %@", error.localizedDescription);
        
        [CaronaeAlertController presentOkAlertWithTitle:@"Não foi possível criar a carona." message:error.localizedDescription];
    }];
}

- (IBAction)didTapCreateButton:(id)sender {
    // Check if the user selected the location and hub
    if (!self.zone || !self.neighborhood || !self.selectedHub) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Dados incompletos" message:@"Ops! Parece que você esqueceu de preencher o local da sua carona."];
        return;
    }
    
    NSDictionary *ride = [self generateRideDictionaryFromView];
    [self savePresetLocationZone:ride[@"myzone"] neighborhood:ride[@"neighborhood"] place:ride[@"place"] route:ride[@"route"] hub:ride[@"hub"] description:ride[@"description"] going:ride[@"going"]];
    
    // Check if the user has selected the routine details
    if (![ride[@"repeats_until"] isKindOfClass:[NSNull class]] && [ride[@"week_days"] isEqualToString:@""]) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Dados incompletos" message:@"Ops! Parece que você esqueceu de marcar os dias da rotina."];
        return;
    }
    
    [self createRide:ride];
}

- (IBAction)slotsStepperChanged:(UIStepper *)sender {
    self.slotsLabel.text = [NSString stringWithFormat:@"%.f", sender.value];
}


#pragma mark - Routine selection buttons

- (IBAction)routineSwitchChanged:(UISwitch *)sender {
    [self.view endEditing:YES];
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


#pragma mark - Other actions

- (IBAction)selectDateTapped:(id)sender {
    [self.view endEditing:YES];
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle: (self.segmentedControl.selectedSegmentIndex == 0)? @"Chegada ao destino" : @"Saída da UFRJ" datePickerMode:UIDatePickerModeDateAndTime selectedDate:self.rideDate target:self action:@selector(timeWasSelected:element:) origin:sender];
    ((UIDatePicker *)datePicker).minimumDate = [NSDate currentHour];
    [datePicker showActionSheetPicker];
}

- (void)timeWasSelected:(NSDate *)selectedTime element:(id)element {
    self.rideDate = selectedTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    [self.arrivalTimeButton setTitle:[dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
}

- (IBAction)directionChanged:(UISegmentedControl *)sender {
    [self.view endEditing:YES];
    NSDictionary *lastRideLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastOfferedRideLocation"];
    if (sender.selectedSegmentIndex == 0) {
        self.hubs = [CaronaeConstants defaults].centers;
        if (lastRideLocation[@"hubGoing"]) {
            self.selectedHub = lastRideLocation[@"hubGoing"];
            [self.center setTitle:self.selectedHub forState:UIControlStateNormal];
        } else {
            self.selectedHub = self.hubs.firstObject;
            [self.center setTitle:self.selectedHub forState:UIControlStateNormal];
        }
    }
    else {
        self.hubs = [CaronaeConstants defaults].hubs;
        if (lastRideLocation[@"hubReturning"]) {
            self.selectedHub = lastRideLocation[@"hubReturning"];
            [self.center setTitle:self.selectedHub forState:UIControlStateNormal];
        } else {
            self.selectedHub = self.hubs.firstObject;
            [self.center setTitle:self.selectedHub forState:UIControlStateNormal];
        }
    }
}

- (IBAction)selectCenterTapped:(id)sender {
    [self.view endEditing:YES];
    
    NSUInteger selectedIndex = [self.hubs indexOfObject:self.selectedHub];
    if (selectedIndex == NSNotFound) {
        selectedIndex = 0;
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"Selecione um centro"
                                            rows:self.hubs
                                initialSelection:selectedIndex
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           self.selectedHub = selectedValue;
                                           [self.center setTitle:selectedValue forState:UIControlStateNormal];
                                       }
                                     cancelBlock:nil origin:sender];
}

- (void)hasSelectedNeighborhood:(NSString *)neighborhood inZone:(NSString *)zone {
    self.zone = zone;
    self.neighborhood = neighborhood;
    [self.neighborhoodButton setTitle:self.neighborhood forState:UIControlStateNormal];
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


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewZones"]) {
        ZoneSelectionViewController *vc = segue.destinationViewController;
        vc.type = ZoneSelectionZone;
        vc.delegate = self;
    }
}

@end
