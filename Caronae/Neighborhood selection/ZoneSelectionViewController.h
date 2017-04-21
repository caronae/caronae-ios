@import UIKit;

typedef enum {
    NeighborhoodSelectionOne,
    NeighborhoodSelectionMany
} NeighborhoodSelectionType;

@protocol ZoneSelectionDelegate <NSObject>

- (void)hasSelectedNeighborhoods:(NSArray *)neighborhoods inZone:(NSString *)zone;

@end

@interface ZoneSelectionViewController : UITableViewController

@property (nonatomic) NSString *selectedZone;
@property (nonatomic) NeighborhoodSelectionType neighborhoodSelectionType;
@property (nonatomic, weak) id<ZoneSelectionDelegate> delegate;

@end
