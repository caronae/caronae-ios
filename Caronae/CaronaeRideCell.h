#import <UIKit/UIKit.h>

@class Ride;

@interface CaronaeRideCell : UITableViewCell

/**
 *  Configures the cell with a Ride object, updating the cell's labels and style accordingly.
 *
 *  @param ride A Ride object.
 */
- (void)configureCellWithRide:(NSDictionary *)ride;

@property (nonatomic, readonly) Ride *ride;
@property (nonatomic, readonly) UIColor *color;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrivalDateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *slotsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photo;

@end
