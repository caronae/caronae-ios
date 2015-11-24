#import <UIKit/UIKit.h>

@interface CaronaeRideTableViewCell : UITableViewCell

- (void)configureCellWithRide:(NSDictionary *)ride;

@property (nonatomic, readonly) NSDictionary *ride;

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
