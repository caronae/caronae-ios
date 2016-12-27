#import <UIKit/UIKit.h>

@class Chat;

@interface ChatViewController : UIViewController

- (instancetype)initWithChat:(Chat *)chat andColor:(UIColor *)color;

@property (nonatomic) Chat *chat;
@property (nonatomic) UIColor *color;

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIToolbar *toolBar;
@property (nonatomic) UITextView *textView;
@property (nonatomic) UIButton *sendButton;

@end
