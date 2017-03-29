#import "RideListController.h"

@class FilterParameters;

@interface SearchResultsViewController : RideListController

- (void)searchedForRideWithParameters:(FilterParameters *)parameters;

@property (nonatomic) NSInteger previouslySelectedSegmentIndex;

@end
