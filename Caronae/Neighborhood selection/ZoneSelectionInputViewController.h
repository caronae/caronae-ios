@import UIKit;
#import "ZoneSelectionViewController.h"

@interface ZoneSelectionInputViewController : UIViewController

@property (nonatomic) NeighborhoodSelectionType neighborhoodSelectionType;
@property (nonatomic, assign) id<ZoneSelectionDelegate> delegate;

@end
