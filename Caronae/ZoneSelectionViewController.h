#import <UIKit/UIKit.h>

typedef enum {
    ZoneSelectionZone,
    ZoneSelectionNeighborhood
} ZoneSelectionType;

@interface ZoneSelectionViewController : UITableViewController

@property (nonatomic) NSArray *zones;
@property (nonatomic) ZoneSelectionType type;

@end
