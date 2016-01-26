#import <UIKit/UIKit.h>

@class Ride;

@protocol RideDelegate <NSObject>

@optional
- (void)didDeleteRide:(Ride *)ride;

@end

@interface RideViewController : UIViewController

@property (nonatomic) Ride *ride;
@property (nonatomic, assign) id<RideDelegate> delegate;

@end
