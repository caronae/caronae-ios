#import <UIKit/UIKit.h>

@class Ride;

@interface CaronaeRideCell : UITableViewCell

- (void)configureCellWithRide:(NSDictionary *)ride;

@property (nonatomic, readonly) Ride *ride;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrivalDateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *slotsLabel;

@end
