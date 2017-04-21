#import "RiderCell.h"
#import "Caronae-Swift.h"
#import "UIImageView+crn_setImageWithURL.h"

@interface RiderCell ()

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, readwrite) User *user;

@end


@implementation RiderCell

- (void)configureWithUser:(User *)user {
    self.user = user;
    self.nameLabel.text = user.firstName;
    
    if (user.profilePictureURL.length > 0) {
        [self.photo crn_setImageWithURL:[NSURL URLWithString:user.profilePictureURL]];
    }
}

@end
