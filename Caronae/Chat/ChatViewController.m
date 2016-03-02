#import <AFNetworking/AFNetworking.h>
#import <Google/CloudMessaging.h>
#import "AppDelegate.h"
#import "ChatViewController.h"
#import "MessageBubbleTableViewCell.h"
#import "Message+CoreDataProperties.h"
#import "Notification+CoreDataProperties.h"
#import "NotificationStore.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@end

static const CGFloat toolBarMinHeight = 44.0f;

@implementation ChatViewController

- (instancetype)initWithChat:(Chat *)chat andColor:(UIColor *)color {
    self = [super init];
    if (self) {
        _chat = chat;
        _color = color;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @" - dd/MM - HH:mm";
        
        self.title = [chat.ride.title stringByAppendingString:[dateFormatter stringFromDate:chat.ride.date]];
        
        self.hidesBottomBarWhenPushed = YES;
        
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDelegate.managedObjectContext;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadChatMessages {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(Message.class) inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rideID == %@", @(self.chat.ride.rideID)];
    fetchRequest.predicate = predicate;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sentDate" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSError *error;
    self.chat.loadedMessages = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Whoops, couldn't load: %@", [error localizedDescription]);
    }
}

- (void)appendMessage:(Message *)message {
    self.chat.loadedMessages = [self.chat.loadedMessages arrayByAddingObject:message];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.chat.loadedMessages.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    [self tableViewScrollToBottomAnimated:YES];
}


#pragma mark - UIResponder methods

- (BOOL)canBecomeFirstResponder {
    return YES;
}


#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [notificationCenter addObserver:self selector:@selector(gcmDidReceiveMessage:) name:CaronaeGCMMessageReceivedNotification object:nil];
    
    [self loadChatMessages];
    
    [NotificationStore clearNotificationsForRide:@(self.chat.ride.rideID) ofType:NotificationTypeChat];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self tableViewScrollToBottomAnimated:NO];
}

- (UIView *)inputAccessoryView {
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, toolBarMinHeight - 0.5)];
        _toolBar.backgroundColor = [UIColor whiteColor];
        
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
        _sendButton.tintColor = self.color;
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
    // Hack to trigger autocorrect before sending the text
    [self.textView resignFirstResponder];
    [self.textView becomeFirstResponder];
    
    NSString *messageText = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    User *currentUser = [UserController sharedInstance].user;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(Message.class) inManagedObjectContext:context];
    message.text = messageText;
    message.incoming = @(NO);
    message.sentDate = [NSDate date];
    message.rideID = @(self.chat.ride.rideID);
    message.senderName = currentUser.name;
    message.senderId = currentUser.userID;
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", error.localizedDescription);
    }
    
    [self gcmSendMessage:message];
    [self appendMessage:message];
    self.textView.text = @"";
    self.sendButton.enabled = NO;
}


#pragma mark - GCM methods

- (void)gcmDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *msgType = userInfo[@"msgType"];
    
    // Handle chat messages
    if (msgType && [msgType isEqualToString:@"chat"]) {
        NSNumber *rideID = @([userInfo[@"rideId"] intValue]);
        NSNumber *senderID = @([userInfo[@"senderId"] intValue]);
        NSNumber *currentUserId = [UserController sharedInstance].user.userID;
        
        if ([rideID isEqual:@(self.chat.ride.rideID)] && ![senderID isEqual:currentUserId]) {
            NSLog(@"Chat window did receive message: %@", userInfo[@"message"]);
            
            [self loadChatMessages];
            [self.tableView reloadData];
            [self tableViewScrollToBottomAnimated:YES];
        }
    }
}

- (void)gcmSendMessage:(Message *)message {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *time = [dateFormatter stringFromDate:message.sentDate];
    
    NSDictionary *paramsData = @{
                                 @"to": self.chat.topicID,
                                 @"priority": @"high",
                                 @"content_available": @(YES),
                                 @"data": @{
                                         @"message": message.text,
                                         @"rideId": message.rideID,
                                         @"msgType": @"chat",
                                         @"senderName": message.senderName,
                                         @"senderId": message.senderId,
                                         @"time": time}
                                 };
    
    // Send data message payload
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:CaronaeGCMAPIKey forHTTPHeaderField:@"Authorization"];
    
    [manager POST:CaronaeGCMAPISendURL parameters:paramsData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Message data delivered. Reponse: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error sending message data: %@", error.localizedDescription);
    }];
}


#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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
        cell.tintColor = self.color;
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
    NSString *trimmedText = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.sendButton.enabled = ![trimmedText isEqualToString:@""];
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
