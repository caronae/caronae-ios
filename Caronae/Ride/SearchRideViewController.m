#import <ActionSheetDatePicker.h>
#import <ActionSheetStringPicker.h>
#import "CaronaeAlertController.h"
#import "NSDate+nextHour.h"
#import "SearchRideViewController.h"
#import "ZoneSelectionViewController.h"
#import "Caronae-Swift.h"

@interface SearchRideViewController () <ZoneSelectionDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionControl;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *neighborhoodButton;
@property (weak, nonatomic) IBOutlet UIButton *centerButton;
@property (nonatomic) NSArray *neighborhoods;
@property (nonatomic) NSString *zone;
@property (nonatomic) NSDate *searchedDate;
@property (nonatomic) NSString *selectedHub;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSArray *hubs;
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
    
    // Load last searched direction
    BOOL lastSearchedDirection = [self.userDefaults boolForKey:CaronaePreferenceLastSearchedDirectionKey];
    self.directionControl.selectedSegmentIndex = lastSearchedDirection;
    
    // Load last searched neighborhoods
    NSArray *lastSearchedNeighborhoods = [self.userDefaults arrayForKey:CaronaePreferenceLastSearchedNeighborhoodsKey];
    if (lastSearchedNeighborhoods) {
        self.neighborhoods = lastSearchedNeighborhoods;
    }
    
    // Load last searched center
    NSString *lastSearchedCenter = [self.userDefaults stringForKey:CaronaePreferenceLastSearchedCenterKey];
    self.hubs = [CaronaeConstants defaults].centers;
    if (lastSearchedCenter) {
        self.selectedHub = lastSearchedCenter;
    } else {
        self.selectedHub = self.hubs.firstObject;
    }
    [self.centerButton setTitle:self.selectedHub forState:UIControlStateNormal];
    
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
    
    NSString *buttonTitle = @"";
    for (unsigned int i = 0; i < neighborhoods.count; i++) {
        if (i > 2) {
            buttonTitle = [NSString stringWithFormat:@"%@ + %lu", buttonTitle, (long)neighborhoods.count-i];
            break;
        }
        buttonTitle = [buttonTitle stringByAppendingString:neighborhoods[i]];
        if (i < neighborhoods.count - 1 && i < 2) {
            buttonTitle = [buttonTitle stringByAppendingString:@", "];
        }
    }
    
    [self.neighborhoodButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSearchButton:(id)sender {
    // Validate form
    if (![self isSearchValid]) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Nenhum bairro selecionado" message:@"Ops! Parece que você esqueceu de selecionar em quais bairros está pesquisando a carona."];
        return;
    }

    // Save search parameters for the next search
    [self.userDefaults setObject:self.neighborhoods forKey:CaronaePreferenceLastSearchedNeighborhoodsKey];
    [self.userDefaults setObject:self.selectedHub forKey:CaronaePreferenceLastSearchedCenterKey];
    [self.userDefaults setObject:self.searchedDate forKey:CaronaePreferenceLastSearchedDateKey];
    [self.userDefaults setBool:self.directionControl.selectedSegmentIndex forKey:CaronaePreferenceLastSearchedDirectionKey];
    
    BOOL going = (self.directionControl.selectedSegmentIndex == 0);
    [self.delegate searchedForRideWithCenter:self.selectedHub andNeighborhoods:self.neighborhoods onDate:self.searchedDate going:going];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    self.zone = zone;
    self.neighborhoods = neighborhoods;
}

- (BOOL)isSearchValid {
    // Test if user has selected a neighborhood
    if (self.neighborhoods && self.neighborhoods.count > 0) {
        return true;
    }

    return false;
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
