#import <UIKit/UIKit.h>

@class Ride;

@protocol RideDelegate <NSObject>

- (void)didDeleteRide:(Ride *)ride;

@end

@interface RideViewController : UIViewController

@property (nonatomic) Ride *ride;
@property (nonatomic, assign) id<RideDelegate> delegate;

@end
