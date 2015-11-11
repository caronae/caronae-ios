#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *carModel;
@property (weak, nonatomic) IBOutlet UILabel *carPlate;
@property (weak, nonatomic) IBOutlet UILabel *numDrives;
@property (weak, nonatomic) IBOutlet UILabel *numRides;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

// Numbers
@property (weak, nonatomic) IBOutlet UILabel *joinedDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numDrivesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numRidesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLikesLabel;

// Car details
@property (weak, nonatomic) IBOutlet UILabel *carPlateLabel;
@property (weak, nonatomic) IBOutlet UILabel *carModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *carColorLabel;

@end
