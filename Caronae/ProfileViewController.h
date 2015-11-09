#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *carModel;
@property (weak, nonatomic) IBOutlet UILabel *carPlate;
@property (weak, nonatomic) IBOutlet UILabel *numDrives;
@property (weak, nonatomic) IBOutlet UILabel *numRides;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@end
