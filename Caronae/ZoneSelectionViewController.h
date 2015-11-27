#import <UIKit/UIKit.h>

typedef enum {
    ZoneSelectionZone,
    ZoneSelectionNeighborhood
} ZoneSelectionType;

@protocol ZoneSelectionDelegate <NSObject>

- (void)hasSelectedNeighborhood:(NSString *)neighborhood inZone:(NSString *)zone;

@end

@interface ZoneSelectionViewController : UITableViewController

@property (nonatomic) NSArray *zones;
@property (nonatomic) ZoneSelectionType type;
@property (nonatomic, assign) id<ZoneSelectionDelegate> delegate;

@end
