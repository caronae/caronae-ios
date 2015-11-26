#import <UIKit/UIKit.h>

@class Ride;
@class CaronaeRideCell;

@protocol CaronaeRideCellDelegate <NSObject>
- (void)tappedJoinRide:(CaronaeRideCell *)cell;
@end

@interface CaronaeRideCell : UITableViewCell

- (void)configureCellWithRide:(NSDictionary *)ride canJoin:(BOOL)joinEnabled;

@property (nonatomic, assign) id<CaronaeRideCellDelegate> delegate;
@property (nonatomic, readonly) Ride *ride;

@property (weak, nonatomic) IBOutlet UIView *detailView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrivalDateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *slotsLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsInCommonLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *driverPhoto;
@property (weak, nonatomic) IBOutlet UIButton *requestRideButton;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomToPhotoConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomToDetailViewConstraint;

@end
