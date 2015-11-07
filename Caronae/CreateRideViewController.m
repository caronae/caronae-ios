#import "CreateRideViewController.h"

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

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                           @"slots": self.slotsLabel.text,
                           @"hub": @"",
                           @"description": self.notes.text,
                           @"going": @(self.segmentedControl.selectedSegmentIndex == 0),
                           @"week_days": @"",
                           @"repeats_until": @""
                           };
    NSLog(@"%@", ride);
}

- (IBAction)slotsStepperChanged:(UIStepper *)sender {
    self.slotsLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
}

- (IBAction)routineSwitchChanged:(UISwitch *)sender {
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
