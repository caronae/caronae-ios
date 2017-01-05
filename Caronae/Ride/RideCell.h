@import UIKit;

@class Ride;

@interface RideCell : UITableViewCell

/**
 *  Configures the cell with a Ride object, updating the cell's labels and style accordingly.
 *
 *  @param ride A Ride object.
 */
- (void)configureCellWithRide:(Ride *)ride;

/**
 *  Configures the cell with a Ride object which belongs to a user's ride history, updating the cell's labels and style accordingly.
 *
 *  @param ride A Ride object.
 */
- (void)configureHistoryCellWithRide:(Ride *)ride;

@property (nonatomic, readonly) Ride *ride;
@property (nonatomic, readonly) UIColor *color;
@property (nonatomic) NSInteger badgeCount;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrivalDateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;

@end
