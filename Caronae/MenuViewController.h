#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController

- (void)openRidesHistory;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileCourseLabel;

@end
