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
    }
    return self;
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
