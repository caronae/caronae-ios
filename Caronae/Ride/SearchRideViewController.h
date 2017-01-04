#import <UIKit/UIKit.h>

@protocol SearchRideDelegate <NSObject>
- (void)searchedForRideWithCenter:(NSString *)center andNeighborhoods:(NSArray *)neighborhoods onDate:(NSDate *)date going:(BOOL)going;
@end

@interface SearchRideViewController : UIViewController
@property (nonatomic, assign) id<SearchRideDelegate> delegate;

@property (nonatomic) NSInteger previouslySelectedSegmentIndex;

@end
