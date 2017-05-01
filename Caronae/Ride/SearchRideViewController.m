@import ActionSheetPicker_3_0;

#import "CaronaeAlertController.h"
#import "NSDate+nextHour.h"
#import "SearchRideViewController.h"
#import "SearchResultsViewController.h"
#import "Caronae-Swift.h"

@interface SearchRideViewController () <NeighborhoodSelectionDelegate, HubSelectionDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionControl;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *neighborhoodButton;
@property (weak, nonatomic) IBOutlet UIButton *centerButton;
@property (nonatomic) NSArray *neighborhoods;
@property (nonatomic) NSString *zone;
@property (nonatomic) NSDate *searchedDate;
@property (nonatomic) NSArray *selectedHubs;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSUserDefaults *userDefaults;
@end

@implementation SearchRideViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:CaronaeDateLocaleIdentifier];
    [self.dateFormatter setDateFormat:CaronaeSearchDateFormat];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load last direction
    self.directionControl.selectedSegmentIndex = self.previouslySelectedSegmentIndex;
    
    // Load last searched zone
    NSString *lastSearchedZone = [self.userDefaults stringForKey:CaronaePreferenceLastSearchedZoneKey];
    if (lastSearchedZone) {
        self.zone = lastSearchedZone;
    } else {
        self.zone = @"";
    }
    
    // Load last searched neighborhoods
    NSArray *lastSearchedNeighborhoods = [self.userDefaults arrayForKey:CaronaePreferenceLastSearchedNeighborhoodsKey];
    if (lastSearchedNeighborhoods) {
        self.neighborhoods = lastSearchedNeighborhoods;
    } else {
        self.neighborhoods = @[CaronaeAllNeighborhoodsText];
    }
    
    // Load last searched center
    NSArray *lastSearchedCenters = [self.userDefaults arrayForKey:CaronaePreferenceLastFilteredCentersKey];
    if (lastSearchedCenters) {
        self.selectedHubs = lastSearchedCenters;
    } else {
        self.selectedHubs = @[CaronaeAllHubsText];
    }
    
    // Load last searched date
    NSDate *lastSearchedDate = [self.userDefaults objectForKey:CaronaePreferenceLastSearchedDateKey];
    if (lastSearchedDate && [lastSearchedDate isInTheFuture]) {
        self.searchedDate = lastSearchedDate;
    } else {
        self.searchedDate = [NSDate nextHour];
    }
    
    NSString *dateString = [self.dateFormatter stringFromDate:self.searchedDate];
    [self.dateButton setTitle:dateString forState:UIControlStateNormal];
}

- (void)setNeighborhoods:(NSArray *)neighborhoods {
    _neighborhoods = neighborhoods;
    
    NSString *buttonTitle = neighborhoods.compactString;
    [self.neighborhoodButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)setSelectedHubs:(NSArray *)selectedHubs {
    _selectedHubs = selectedHubs;
    
    NSString *buttonTitle = selectedHubs.compactString;
    [self.centerButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSearchButton:(id)sender {
    // Save search parameters for the next search
    [self.userDefaults setObject:self.zone forKey:CaronaePreferenceLastSearchedZoneKey];
    [self.userDefaults setObject:self.neighborhoods forKey:CaronaePreferenceLastSearchedNeighborhoodsKey];
    [self.userDefaults setObject:self.selectedHubs forKey:CaronaePreferenceLastFilteredCentersKey];
    [self.userDefaults setObject:self.searchedDate forKey:CaronaePreferenceLastSearchedDateKey];
    
    BOOL going = (self.directionControl.selectedSegmentIndex == 0);
    
    FilterParameters *params = [FilterParameters alloc];
    params.hubs = self.selectedHubs;
    params.selectedZone = self.zone;
    params.neighborhoods = self.neighborhoods;
    params.date = self.searchedDate;
    [params setGoing:going];
    
    [self.delegate searchedForRideWithParameters:params];
    [self performSegueWithIdentifier:@"showResultsUnwind" sender:nil];
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
    NSString *dateString = [self.dateFormatter stringFromDate:self.searchedDate];
    [self.dateButton setTitle:dateString forState:UIControlStateNormal];
}

- (IBAction)selectCenterTapped:(id)sender {
    HubSelectionViewController *selectionVC = [HubSelectionViewController makeVCWithSelectionType:SelectionTypeManySelection hubTypeDirection:HubTypeDirectionCenters];
    [selectionVC setDelegate:self];
    [self.navigationController pushViewController:selectionVC animated:YES];
}

- (IBAction)selectNeighborhoodTapped:(id)sender {
    NeighborhoodSelectionViewController *selectionVC = [NeighborhoodSelectionViewController makeVCWithSelectionType:SelectionTypeManySelection];
    [selectionVC setDelegate:self];
    [self.navigationController pushViewController:selectionVC animated:YES];
}

- (void)hasSelectedWithHubs:(NSArray<NSString *> *)hubs {
    self.selectedHubs = hubs;
}

- (void)hasSelectedWithNeighborhoods:(NSArray<NSString *> *)neighborhoods inZone:(NSString *)zone {
    self.zone = zone;
    self.neighborhoods = neighborhoods;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showResultsUnwind"]) {
        SearchResultsViewController *vc = segue.destinationViewController;
        vc.previouslySelectedSegmentIndex = self.directionControl.selectedSegmentIndex;
    }
}

@end
