#import "RideListController.h"

@class FilterParameters;
@protocol SearchRideDelegate;

@interface SearchResultsViewController : RideListController

- (void)searchedForRideWithParameters:(FilterParameters *)parameters;

@property (nonatomic) NSInteger previouslySelectedSegmentIndex;

@end
