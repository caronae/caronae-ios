#import <UIKit/UIKit.h>
#import "ZoneSelectionViewController.h"

@interface ZoneSelectionInputViewController : UIViewController

@property (nonatomic) NeighborhoodSelectionType neighborhoodSelectionType;
@property (nonatomic, assign) id<ZoneSelectionDelegate> delegate;

@end
