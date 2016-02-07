#import <UIKit/UIKit.h>

@class Ride;

@protocol RideDelegate <NSObject>

@optional
- (void)didDeleteRide:(Ride *)ride;

@end

@interface RideViewController : UIViewController

@property (nonatomic) Ride *ride;
@property (nonatomic, assign) id<RideDelegate> delegate;

// Ride info
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *referenceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *driverPhoto;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverCourseLabel;
@property (weak, nonatomic) IBOutlet UILabel *mutualFriendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UIView *carDetailsView;
@property (weak, nonatomic) IBOutlet UILabel *carPlateLabel;
@property (weak, nonatomic) IBOutlet UILabel *carModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *carColorLabel;

// Assets
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *ridersView;
@property (weak, nonatomic) IBOutlet UIView *mutualFriendsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mutualFriendsCollectionHeight;
@property (weak, nonatomic) IBOutlet UIView *finishRideView;
@property (weak, nonatomic) IBOutlet UICollectionView *ridersCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ridersCollectionViewHeight;
@property (weak, nonatomic) IBOutlet UICollectionView *mutualFriendsCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *clockIcon;
@property (weak, nonatomic) IBOutlet UIImageView *carIconPlate;
@property (weak, nonatomic) IBOutlet UIImageView *carIconModel;
@property (weak, nonatomic) IBOutlet UIImageView *carIconColor;
@property (weak, nonatomic) IBOutlet UITableView *requestsTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *requestsTableHeight;

// Buttons
@property (weak, nonatomic) IBOutlet UIButton *requestRideButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *finishRideButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *chatButton;

@end
