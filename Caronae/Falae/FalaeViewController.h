@import UIKit;

@class User;

@interface FalaeViewController : UIViewController

- (void)setReport:(User *)user;

@property (weak, nonatomic) IBOutlet UIButton *typeButton;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (nonatomic) UIBarButtonItem *loadingButton;

@end
