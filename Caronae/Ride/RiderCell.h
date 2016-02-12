#import <UIKit/UIKit.h>

@interface RiderCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic) User *user;
@end
