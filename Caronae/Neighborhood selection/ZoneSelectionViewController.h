#import <UIKit/UIKit.h>

typedef enum {
    ZoneSelectionZone,
    ZoneSelectionNeighborhood
} ZoneSelectionType;

typedef enum {
    NeighborhoodSelectionOne,
    NeighborhoodSelectionMany
} NeighborhoodSelectionType;

@protocol ZoneSelectionDelegate <NSObject>

@optional
- (void)hasSelectedNeighborhood:(NSString *)neighborhood inZone:(NSString *)zone;

@optional
- (void)hasSelectedNeighborhoods:(NSArray *)neighborhoods inZone:(NSString *)zone;

@end

@interface ZoneSelectionViewController : UITableViewController

@property (nonatomic) NSString *selectedZone;
@property (nonatomic) ZoneSelectionType type;
@property (nonatomic) NeighborhoodSelectionType neighborhoodSelectionType;
@property (nonatomic, assign) id<ZoneSelectionDelegate> delegate;

@end
