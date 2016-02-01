#import <UIKit/UIKit.h>
#import "Chat.h"

@interface ChatViewController : UIViewController

- (instancetype)initWithChat:(Chat *)chat;

@property (nonatomic) Chat *chat;


@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIToolbar *toolBar;
@property (nonatomic) UITextView *textView;
@property (nonatomic) UIButton *sendButton;

@end
