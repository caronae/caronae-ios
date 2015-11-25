#import "SearchRideViewController.h"
#import <ActionSheetDatePicker.h>
#import <ActionSheetStringPicker.h>

@interface SearchRideViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionControl;
@property (weak, nonatomic) IBOutlet UITextField *neighborhood;
@property (nonatomic) NSDate *searchedDate;
@property (nonatomic) NSString *selectedCenter;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *centerButton;
@property (nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation SearchRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *lastSearchedNeighborhood = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSearchedNeighborhood"];
    if (lastSearchedNeighborhood) {
        self.neighborhood.text = lastSearchedNeighborhood;
    }
    
    NSString *lastSearchedCenter = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSearchedCenter"];
    if (lastSearchedCenter) {
        self.selectedCenter = lastSearchedCenter;
        [self.centerButton setTitle:lastSearchedCenter forState:UIControlStateNormal];
    }
    else {
        self.selectedCenter = @"CT";
        [self.centerButton setTitle:@"CT" forState:UIControlStateNormal];
    }
    
    self.searchedDate = [NSDate date];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    [self.dateButton setTitle:[self.dateFormatter stringFromDate:self.searchedDate] forState:UIControlStateNormal];
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
        [[NSUserDefaults standardUserDefaults] setObject:self.selectedCenter forKey:@"lastSearchedCenter"];
        [self.delegate searchedForRideWithCenter:self.selectedCenter andNeighborhood:neighborhood onDate:self.searchedDate going:going];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)didTapDate:(id)sender {
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Hora" datePickerMode:UIDatePickerModeDateAndTime selectedDate:self.searchedDate target:self action:@selector(timeWasSelected:element:) origin:sender];
    [datePicker showActionSheetPicker];
}

- (void)timeWasSelected:(NSDate *)selectedTime element:(id)element {
    self.searchedDate = selectedTime;
    [self.dateButton setTitle:[self.dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
}

- (IBAction)selectCenterTapped:(id)sender {
    NSArray *centers = @[@"CT", @"CCMN", @"CCS", @"Letras", @"Reitoria"];
    long lastSearchedCenterIndex = [centers indexOfObject:self.selectedCenter];
    [ActionSheetStringPicker showPickerWithTitle:@"Selecione um centro"
                                            rows:centers
                                initialSelection:lastSearchedCenterIndex
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           self.selectedCenter = selectedValue;
                                           [self.centerButton setTitle:selectedValue forState:UIControlStateNormal];
                                       }
                                     cancelBlock:nil origin:sender];
}

@end
