#import "ChatViewController.h"
#import "MessageBubbleTableViewCell.h"
#import "Message.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@end

static const CGFloat toolBarMinHeight = 44.0f;

@implementation ChatViewController

- (instancetype)initWithChat:(Chat *)chat {
    self = [super init];
    if (self) {
        _chat = chat;
        self.title = [NSString stringWithFormat:@"Chat - Carona %lu", chat.ride.rideID];
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UIResponder methods

- (BOOL)canBecomeFirstResponder {
    return YES;
}


#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chat.loadedMessages = @[
                                 [[Message alloc] initWithIncoming:YES text:@"Mensagem que recebi!" sentDate:[NSDate dateWithTimeIntervalSinceNow:-60*60*24*2-60*60]],
                                 [[Message alloc] initWithIncoming:NO text:@"Mensagem que enviei." sentDate:[NSDate dateWithTimeIntervalSinceNow:-60*60*24*2]],
                                 [[Message alloc] initWithIncoming:NO text:@"o enable debug logging set the following application argument" sentDate:[NSDate dateWithTimeIntervalSinceNow:-60*60*24*2]],
    ];
    
    self.view.backgroundColor = [UIColor whiteColor]; // smooths push animation
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, toolBarMinHeight, 0);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.0f;
    [self.view addSubview:self.tableView];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
}

- (UIView *)inputAccessoryView {
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, toolBarMinHeight - 0.5)];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.backgroundColor = [UIColor colorWithWhite:250.0/255.0 alpha:1];
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:17];
        _textView.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1].CGColor;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.cornerRadius = 5;
        _textView.scrollsToTop = NO;
        _textView.textContainerInset = UIEdgeInsetsMake(4, 3, 3, 3);
        [_toolBar addSubview:_textView];
        
        _sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _sendButton.enabled = NO;
        _sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_sendButton setTitle:@"Enviar" forState:UIControlStateNormal];
        
        _sendButton.contentEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
        [_sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:_sendButton];
        
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _sendButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeLeft multiplier:1 constant:8]];
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeTop multiplier:1 constant:7.5]];
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_sendButton attribute:NSLayoutAttributeLeft multiplier:1 constant:-2]];
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeBottom multiplier:1 constant:-8]];
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:_sendButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:_sendButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeBottom multiplier:1 constant:-4.5]];
    }
    
    return _toolBar;
}


#pragma mark - Actions

- (void)sendAction:(id)sender {
    Message *message = [[Message alloc] initWithIncoming:NO text:self.textView.text sentDate:[NSDate date]];
    self.chat.loadedMessages = [self.chat.loadedMessages arrayByAddingObject:message];
    
    self.textView.text = @"";
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.chat.loadedMessages.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    [self tableViewScrollToBottomAnimated:YES];
}


#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return self.chat.loadedMessages.count;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chat.loadedMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = NSStringFromClass(MessageBubbleTableViewCell.class);
    MessageBubbleTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MessageBubbleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Message *message = self.chat.loadedMessages[indexPath.row];
    [cell configureWithMessage:message];
    
    return cell;
}

- (void)tableViewScrollToBottomAnimated:(BOOL)animated {
    long int numberOfRows = [self.tableView numberOfRowsInSection:0];
    if (numberOfRows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}


#pragma mark - UITextView methods

- (void)textViewDidChange:(UITextView *)textView {
    self.sendButton.enabled = [textView hasText];
}


#pragma mark - UIKeyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect frameNew = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat insetNewBottom = [self.tableView convertRect:frameNew fromView:nil].size.height;
    UIEdgeInsets insetOld = self.tableView.contentInset;
    CGFloat insetChange = insetNewBottom - insetOld.bottom;
    CGFloat overflow = self.tableView.contentSize.height - (self.tableView.frame.size.height - insetOld.top - insetOld.bottom);
    
    void (^animations)() = ^void() {
        if (!(self.tableView.tracking || self.tableView.decelerating)) {
            // Move content with keyboard
            if (overflow > 0) { // scrollable before
                self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + insetChange);
                if (self.tableView.contentOffset.y < -insetOld.top) {
                    self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, - insetOld.top);
                }
            }
            else if (insetChange > -overflow) { // scrollable after
                self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + insetChange + overflow);
            }
        }
    };
    
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (duration > 0) {
        UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:animations completion:nil];
    }
    else {
        animations();
    }
}

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect frameNew = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat insetNewBottom = [self.tableView convertRect:frameNew fromView:nil].size.height;
    
    // Inset `tableView` with keyboard
    CGFloat contentOffsetY = self.tableView.contentOffset.y;
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, insetNewBottom, self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, self.tableView.scrollIndicatorInsets.left, insetNewBottom, self.tableView.scrollIndicatorInsets.right);
    
    // Prevents jump after keyboard dismissal
    if (self.tableView.tracking || self.tableView.decelerating) {
        self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, contentOffsetY);
    }
    
}

@end
