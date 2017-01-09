@import UIKit;
@import Realm;

@class Ride;

@interface ChatViewController : UIViewController

- (instancetype)initWithRide:(Ride *)ride andColor:(UIColor *)color;
- (void)scrollToBottomAnimated:(BOOL)animated;

@property (nonatomic) Ride *ride;
@property (nonatomic) UIColor *color;

@property (nonatomic) id messages;

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIToolbar *toolBar;
@property (nonatomic) UITextView *textView;
@property (nonatomic) UIButton *sendButton;

@property (nonatomic) RLMNotificationToken *messagesNotificationToken;

@end
