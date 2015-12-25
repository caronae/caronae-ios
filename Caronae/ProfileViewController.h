#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController

@property (nonatomic) NSDictionary *user;

// ID
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

// Mutual friends
@property (weak, nonatomic) IBOutlet UIView *mutualFriendsView;
@property (weak, nonatomic) IBOutlet UICollectionView *mutualFriendsCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *mutualFriendsLabel;

// Numbers
@property (weak, nonatomic) IBOutlet UILabel *joinedDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numDrivesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numRidesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLikesLabel;

// Car details
@property (weak, nonatomic) IBOutlet UIView *carDetailsView;
@property (weak, nonatomic) IBOutlet UILabel *carPlateLabel;
@property (weak, nonatomic) IBOutlet UILabel *carModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *carColorLabel;

@end
