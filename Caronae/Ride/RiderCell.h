@import UIKit;

@class User;

@interface RiderCell : UICollectionViewCell

- (void)configureWithUser:(User *)user;

@property (nonatomic, readonly) User *user;

@end
