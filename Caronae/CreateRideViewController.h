#import <UIKit/UIKit.h>

@interface CreateRideViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *origin;
@property (weak, nonatomic) IBOutlet UITextField *reference;
@property (weak, nonatomic) IBOutlet UITextField *route;
@property (weak, nonatomic) IBOutlet UISwitch *routineSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIStepper *slotsStepper;
@property (weak, nonatomic) IBOutlet UILabel *slotsLabel;
@property (weak, nonatomic) IBOutlet UITextView *notes;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end
