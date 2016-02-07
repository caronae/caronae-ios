#import <AFNetworking/AFNetworking.h>
#import <CoreData/CoreData.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "AppDelegate.h"
#import "CaronaeAlertController.h"
#import "CaronaeDefaults.h"
#import "ActiveRidesViewController.h"
#import "CaronaeRideCell.h"
#import "Chat.h"
#import "ChatStore.h"
#import "Notification+CoreDataProperties.h"
#import "RideViewController.h"
#import "Ride.h"

@interface ActiveRidesViewController ()
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation ActiveRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
    
    [self loadActiveRides];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateNotifications:) name:CaronaeDidUpdateNotifications object:nil];
    
    [self updateBadgeCount];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadActiveRides];
}

- (void)refreshTable:(id)sender {
    if (self.refreshControl.refreshing) {
        [self loadActiveRides];
    }
}

- (void)updateBadgeCount {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(Notification.class) inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.includesPropertyValues = NO;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == 'chat' AND read == NO"];
    fetchRequest.predicate = predicate;
    
    NSError *error;
    NSArray<Notification *> *unreadChatNotifications = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Whoops, couldn't load unread notifications: %@", [error localizedDescription]);
        return;
    }
    
    if (unreadChatNotifications.count > 0) {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)unreadChatNotifications.count];
    }
    else {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
}

- (void)didUpdateNotifications:(NSNotification *)notification {
    NSString *msgType = notification.userInfo[@"msgType"];
    
    if ([msgType isEqualToString:@"chat"]) {
        [self updateBadgeCount];
    }
}

#pragma mark - Rides methods

- (void)loadActiveRides {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/getMyActiveRides"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.refreshControl endRefreshing];
        
        NSError *responseError;
        NSArray *rides = [ActiveRidesViewController parseResultsFromResponse:responseObject withError:&responseError];
        if (!responseError) {
            self.rides = rides;
            [self.tableView reloadData];
            if (self.rides.count > 0) {
                self.tableView.backgroundView = nil;
                
                // Initialise chats
                for (Ride *ride in self.rides) {
                    // If chat doesn't exist in store, create it and subscribe to it
                    if (![ChatStore chatForRide:ride]) {
                        Chat *chat = [[Chat alloc] initWithRide:ride];
                        if (!chat.subscribed) {
                            [chat subscribe];
                        }
                        [ChatStore setChat:chat forRide:ride];
                    }
                }
            }
            else {
                self.tableView.backgroundView = self.emptyTableLabel;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        self.tableView.backgroundView = self.errorLabel;
        
        if (operation.response.statusCode == 403) {
            [CaronaeAlertController presentOkAlertWithTitle:@"Erro de autorização" message:@"Ocorreu um erro autenticando seu usuário. Seu token pode ter sido suspenso ou expirado." handler:^{
                [CaronaeDefaults signOut];
            }];
        }
        else {
            NSLog(@"Error loading active rides: %@", error.localizedDescription);
        }
    }];
}

+ (NSArray *)parseResultsFromResponse:(id)responseObject withError:(NSError *__autoreleasing *)err {
    // Check if we received an array of the rides
    if ([responseObject isKindOfClass:NSArray.class]) {
        NSMutableArray *rides = [NSMutableArray arrayWithCapacity:((NSArray*)responseObject).count];
        for (NSDictionary *rideDictionary in responseObject) {
            Ride *ride = [[Ride alloc] initWithDictionary:rideDictionary];
            [rides addObject:ride];
        }
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        return [rides sortedArrayUsingDescriptors:@[sortDescriptor]];
    }
    else {
        if (err) {
            NSDictionary *errorInfo = @{
                                        NSLocalizedDescriptionKey: NSLocalizedString(@"Unexpected server response.", nil)
                                        };
            *err = [NSError errorWithDomain:CaronaeErrorDomain code:CaronaeErrorInvalidResponse userInfo:errorInfo];
        }
    }
    
    return nil;
}

@end
