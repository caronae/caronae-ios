@import UIKit;

@class User;

@interface ProfileViewController : UIViewController

@property (nonatomic) User *user;

// ID
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;

// Mutual friends
@property (weak, nonatomic) IBOutlet UIView *mutualFriendsView;
@property (weak, nonatomic) IBOutlet UICollectionView *mutualFriendsCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *mutualFriendsLabel;

// Numbers
@property (weak, nonatomic) IBOutlet UILabel *joinedDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numDrivesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numRidesLabel;

// Car details
@property (weak, nonatomic) IBOutlet UIView *carDetailsView;
@property (weak, nonatomic) IBOutlet UILabel *carPlateLabel;
@property (weak, nonatomic) IBOutlet UILabel *carModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *carColorLabel;

@end
