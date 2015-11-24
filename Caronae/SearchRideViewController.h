#import <UIKit/UIKit.h>

@protocol SeachRideDelegate <NSObject>
- (void)searchedForRideWithCenter:(NSString *)center andNeighborhood:(NSString *)neighborhood onDate:(NSDate *)date going:(BOOL)going;
@end

@interface SearchRideViewController : UIViewController
@property (nonatomic, assign) id<SeachRideDelegate> delegate;
@end
