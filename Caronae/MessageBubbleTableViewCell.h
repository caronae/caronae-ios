#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessageBubbleTableViewCell : UITableViewCell

- (void)configureWithMessage:(Message *)message;

@property (nonatomic) UIView *bubbleView;
@property (nonatomic) UILabel *messageLabel;

@end
