@import UIKit;
@class FilterParameters;
@protocol NeighborhoodSelectionDelegate;
@protocol HubSelectionDelegate;

@protocol SearchRideDelegate <NSObject>
- (void)searchedForRideWithParameters:(FilterParameters *)parameters;
@end

@interface SearchRideViewController : UIViewController
@property (nonatomic, assign) id<SearchRideDelegate> delegate;

@property (nonatomic) NSInteger previouslySelectedSegmentIndex;

@end
