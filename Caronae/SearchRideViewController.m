#import "SearchRideViewController.h"
#import <ActionSheetDatePicker.h>
#import <ActionSheetStringPicker.h>
#import "NSDate+nextHour.h"
#import "CaronaeDefaults.h"

@interface SearchRideViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionControl;
@property (weak, nonatomic) IBOutlet UITextField *neighborhood;
@property (nonatomic) NSDate *searchedDate;
@property (nonatomic) NSString *selectedHub;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *centerButton;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSArray *hubs;
@end

@implementation SearchRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *lastSearchedNeighborhood = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSearchedNeighborhood"];
    if (lastSearchedNeighborhood) {
        self.neighborhood.text = lastSearchedNeighborhood;
    }
    
    NSString *lastSearchedCenter = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSearchedCenter"];
    self.hubs = [CaronaeDefaults defaults].centers;
    if (lastSearchedCenter) {
        self.selectedHub = lastSearchedCenter;
    }
    else {
        self.selectedHub = self.hubs[0];
    }
    [self.centerButton setTitle:self.selectedHub forState:UIControlStateNormal];
    
    self.searchedDate = [NSDate nextHour];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    [self.dateButton setTitle:[self.dateFormatter stringFromDate:self.searchedDate] forState:UIControlStateNormal];
    
    self.directionControl.layer.cornerRadius = 8.0;
    self.directionControl.layer.borderColor = [UIColor colorWithWhite:0.690 alpha:1.000].CGColor;
    self.directionControl.layer.borderWidth = 2.0f;
    self.directionControl.layer.masksToBounds = YES;
}

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSearchButton:(id)sender {
    NSString *neighborhood = self.neighborhood.text;
    BOOL going = (self.directionControl.selectedSegmentIndex == 0);
    
    // Test if user has selected a neighborhood
    if (![neighborhood isEqualToString:@""]) {
        [[NSUserDefaults standardUserDefaults] setObject:neighborhood forKey:@"lastSearchedNeighborhood"];
        if (going) {
            [[NSUserDefaults standardUserDefaults] setObject:self.selectedHub forKey:@"lastSearchedCenter"];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:self.selectedHub forKey:@"lastSearchedHub"];
        }
        [self.delegate searchedForRideWithCenter:self.selectedHub andNeighborhood:neighborhood onDate:self.searchedDate going:going];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)didTapDate:(id)sender {
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Hora" datePickerMode:UIDatePickerModeDateAndTime selectedDate:self.searchedDate target:self action:@selector(timeWasSelected:element:) origin:sender];
    ((UIDatePicker *)datePicker).minuteInterval = 30;
    [datePicker showActionSheetPicker];
}

- (void)timeWasSelected:(NSDate *)selectedTime element:(id)element {
    self.searchedDate = selectedTime;
    [self.dateButton setTitle:[self.dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
}

- (IBAction)directionChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        NSString *lastSearchedCenter = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSearchedCenter"];
        self.hubs = [CaronaeDefaults defaults].centers;
        if (lastSearchedCenter) {
            self.selectedHub = lastSearchedCenter;
        }
        else {
            self.selectedHub = self.hubs[0];
        }
    }
    else {
        NSString *lastSearchedHubs = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSearchedHub"];
        self.hubs = [CaronaeDefaults defaults].hubs;
        if (lastSearchedHubs) {
            self.selectedHub = lastSearchedHubs;
        }
        else {
            self.selectedHub = self.hubs[0];
        }
    }
    [self.centerButton setTitle:self.selectedHub forState:UIControlStateNormal];
}

- (IBAction)selectCenterTapped:(id)sender {
    long lastSearchedCenterIndex = [self.hubs indexOfObject:self.selectedHub];
    [ActionSheetStringPicker showPickerWithTitle:@"Selecione um centro"
                                            rows:self.hubs
                                initialSelection:lastSearchedCenterIndex
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           self.selectedHub = selectedValue;
                                           [self.centerButton setTitle:selectedValue forState:UIControlStateNormal];
                                       }
                                     cancelBlock:nil origin:sender];
}

@end
