@import UIKit;

@class Message;

@interface MessageBubbleTableViewCell : UITableViewCell

- (void)configureWithMessage:(Message *)message;

@property (nonatomic) UIView *bubbleView;
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) UILabel *senderLabel;
@property (nonatomic) UILabel *timeLabel;

@end
