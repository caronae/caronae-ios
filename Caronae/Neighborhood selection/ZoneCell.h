@import UIKit;

#import "ZoneSelectionViewController.h"

@interface ZoneCell : UITableViewCell

- (void)setupCellWithZone:(NSString *)zone color:(UIColor *)color;
- (void)setupCellWithNeighborhood:(NSString *)neighborhood color:(UIColor *)color;

@end
