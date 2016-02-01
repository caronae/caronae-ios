#import "ChatViewController.h"
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

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chat.loadedMessages = @[
                                 [[Message alloc] initWithIncoming:YES text:@"Mensagem que recebi!" sentDate:[NSDate dateWithTimeIntervalSinceNow:-60*60*24*2-60*60]],
                                 [[Message alloc] initWithIncoming:NO text:@"Mensagem que enviei." sentDate:[NSDate dateWithTimeIntervalSinceNow:-60*60*24*2]],
    ];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, toolBarMinHeight, 0);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:self.tableView];
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
        _sendButton.enabled = YES;
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


- (void)sendAction:(id)sender {
    NSLog(@"Tap send");
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Message Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Message Cell"];
    }
    
    Message *message = self.chat.loadedMessages[indexPath.row];
    cell.textLabel.text = message.text;
    
    return cell;
}

@end
