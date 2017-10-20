@import UIKit;

@class User;
@class CaronaePhoneTextField;
@protocol NeighborhoodSelectionDelegate;

@interface EditProfileViewController : UIViewController

- (User *)generateUserFromView;

@property (nonatomic) User *user;
@property (nonatomic) BOOL completeProfileMode;

// Profile
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UILabel *joinedDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numDrivesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numRidesLabel;

// Contacts
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet CaronaePhoneTextField *phoneTextField;

// Location
@property (weak, nonatomic) IBOutlet UIButton *neighborhoodButton;

// Car details
@property (weak, nonatomic) IBOutlet UIView *carDetailsView;
@property (weak, nonatomic) IBOutlet UISwitch *hasCarSwitch;
@property (weak, nonatomic) IBOutlet UITextField *carPlateTextField;
@property (weak, nonatomic) IBOutlet UITextField *carModelTextField;
@property (weak, nonatomic) IBOutlet UITextField *carColorTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *carDetailsHeight;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
