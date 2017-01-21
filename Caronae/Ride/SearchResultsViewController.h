#import "RideListController.h"

@interface SearchResultsViewController : RideListController

- (void)searchedForRideWithCenter:(NSString *)center andNeighborhoods:(NSArray *)neighborhoods onDate:(NSDate *)date going:(BOOL)going;

@property (nonatomic) NSInteger previouslySelectedSegmentIndex;

@end
