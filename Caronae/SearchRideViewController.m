#import <ActionSheetDatePicker.h>
#import <ActionSheetStringPicker.h>
#import "NSDate+nextHour.h"
#import "ZoneSelectionViewController.h"
#import "SearchRideViewController.h"

@interface SearchRideViewController () <ZoneSelectionDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionControl;
@property (nonatomic) NSArray *neighborhoods;
@property (nonatomic) NSString *zone;
@property (nonatomic) NSDate *searchedDate;
@property (nonatomic) NSString *selectedHub;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *neighborhoodButton;
@property (weak, nonatomic) IBOutlet UIButton *centerButton;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSArray *hubs;
@end

@implementation SearchRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *lastSearchedNeighborhoods = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSearchedNeighborhoods"];
    if (lastSearchedNeighborhoods) {
        self.neighborhoods = lastSearchedNeighborhoods;
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

- (void)setNeighborhoods:(NSArray *)neighborhoods {
    _neighborhoods = neighborhoods;
    
    NSString *buttonTitle = @"";
    for (unsigned int i = 0; i < neighborhoods.count; i++) {
        if (i > 2) {
            buttonTitle = [buttonTitle stringByAppendingString:@"..."];
            break;
        }
        buttonTitle = [buttonTitle stringByAppendingString:neighborhoods[i]];
        if (i < neighborhoods.count - 1) {
            buttonTitle = [buttonTitle stringByAppendingString:@", "];
        }
    }
    
    [self.neighborhoodButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSearchButton:(id)sender {
    BOOL going = (self.directionControl.selectedSegmentIndex == 0);
    
    // Test if user has selected a neighborhood
    if (self.neighborhoods) {
        [[NSUserDefaults standardUserDefaults] setObject:self.neighborhoods forKey:@"lastSearchedNeighborhoods"];
        [[NSUserDefaults standardUserDefaults] setObject:self.selectedHub forKey:@"lastSearchedCenter"];
        [self.delegate searchedForRideWithCenter:self.selectedHub andNeighborhoods:self.neighborhoods onDate:self.searchedDate going:going];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)didTapDate:(id)sender {
    [self.view endEditing:YES];
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Hora" datePickerMode:UIDatePickerModeDateAndTime selectedDate:self.searchedDate target:self action:@selector(timeWasSelected:element:) origin:sender];
    ((UIDatePicker *)datePicker).minuteInterval = 30;
    ((UIDatePicker *)datePicker).minimumDate = [NSDate currentHour];
    [datePicker showActionSheetPicker];
}

- (void)timeWasSelected:(NSDate *)selectedTime element:(id)element {
    self.searchedDate = selectedTime;
    [self.dateButton setTitle:[self.dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
}

- (IBAction)selectCenterTapped:(id)sender {
    [self.view endEditing:YES];
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

- (void)hasSelectedNeighborhoods:(NSArray *)neighborhoods inZone:(NSString *)zone {
    NSLog(@"User has selected %@ in %@", neighborhoods, zone);
    self.zone = zone;
    self.neighborhoods = neighborhoods;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewZones"]) {
        ZoneSelectionViewController *vc = segue.destinationViewController;
        vc.type = ZoneSelectionZone;
        vc.neighborhoodSelectionType = NeighborhoodSelectionMany;
        vc.delegate = self;
    }
}


@end
