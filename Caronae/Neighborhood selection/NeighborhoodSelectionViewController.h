@import UIKit;

#import "ZoneSelectionViewController.h"

@protocol NeighborhoodSelectionDelegate <NSObject>

- (void)hasSelectedNeighborhoods:(NSArray *)neighborhoods;

@end


@interface NeighborhoodSelectionViewController : UITableViewController

@property (nonatomic) NSString *selectedZone;
@property (nonatomic) NeighborhoodSelectionType neighborhoodSelectionType;
@property (nonatomic, weak) id<NeighborhoodSelectionDelegate> delegate;

@end
