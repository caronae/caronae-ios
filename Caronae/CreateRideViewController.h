#import <UIKit/UIKit.h>

@interface CreateRideViewController : UIViewController

- (NSDictionary *)generateRideDictionaryFromView;
+ (NSArray *)parseCreateRidesFromResponse:(id)responseObject withError:(NSError **)err;

@property (weak, nonatomic) IBOutlet UIButton *neighborhoodButton;
@property (weak, nonatomic) IBOutlet UITextField *reference;
@property (weak, nonatomic) IBOutlet UITextField *route;
@property (weak, nonatomic) IBOutlet UIButton *center;
@property (weak, nonatomic) IBOutlet UISwitch *routineSwitch;
@property (weak, nonatomic) IBOutlet UIStepper *slotsStepper;
@property (weak, nonatomic) IBOutlet UILabel *slotsLabel;
@property (weak, nonatomic) IBOutlet UITextView *notes;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *createRideButton;

@property (weak, nonatomic) IBOutlet UIView *routinePatternView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *routinePatternHeight;

@property (weak, nonatomic) IBOutlet UIButton *routineMonButton;
@property (weak, nonatomic) IBOutlet UIButton *routineTueButton;
@property (weak, nonatomic) IBOutlet UIButton *routineWedButton;
@property (weak, nonatomic) IBOutlet UIButton *routineThuButton;
@property (weak, nonatomic) IBOutlet UIButton *routineFriButton;
@property (weak, nonatomic) IBOutlet UIButton *routineSatButton;
@property (weak, nonatomic) IBOutlet UIButton *routineSunButton;

@property (weak, nonatomic) IBOutlet UIButton *routineDuration2MonthsButton;
@property (weak, nonatomic) IBOutlet UIButton *routineDuration3MonthsButton;
@property (weak, nonatomic) IBOutlet UIButton *routineDuration4MonthsButton;
@property (weak, nonatomic) IBOutlet UIButton *arrivalTimeButton;

@property (nonatomic) NSDate *rideDate;
@property (nonatomic) NSMutableArray *weekDays;
@property (nonatomic) int routineDurationMonths;

@end
