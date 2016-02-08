#import <UIKit/UIKit.h>

@interface CaronaeRiderCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic) User *user;
@end
