#import <AFNetworking/AFNetworking.h>
#import <CoreData/CoreData.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ActiveRidesViewController.h"
#import "CaronaeDefaults.h"
#import "Chat.h"
#import "ChatStore.h"
#import "Notification+CoreDataProperties.h"
#import "NotificationStore.h"

@interface ActiveRidesViewController ()
@property (nonatomic) NSArray<Notification *> *unreadNotifications;
@end

@implementation ActiveRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
    
    [self updateUnreadNotifications];
    [self loadActiveRides];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateNotifications:) name:CaronaeDidUpdateNotifications object:nil];
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

- (void)updateUnreadNotifications {
    self.unreadNotifications = [NotificationStore getNotificationsOfType:NotificationTypeChat];
    
    if (self.unreadNotifications.count > 0) {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)self.unreadNotifications.count];
    }
    else {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
}

- (void)didUpdateNotifications:(NSNotification *)notification {
    NSString *msgType = notification.userInfo[@"msgType"];
    
    if ([msgType isEqualToString:@"chat"]) {
        [self updateUnreadNotifications];
        [self.tableView reloadData];
    }
}


#pragma mark - Navigation

- (void)openChatForRideWithID:(NSNumber *)rideID {
    Ride *ride;
    
    // Find ride
    for (Ride *r in self.rides) {
        if ([rideID isEqualToNumber:@(r.rideID)]) {
            ride = r;
            break;
        }
    }
    
    if (ride) {
        RideViewController *rideVC = [self rideViewControllerForRide:ride];
        rideVC.shouldOpenChatWindow = YES;
        [self.navigationController pushViewController:rideVC animated:YES];
    }
}


#pragma mark - Rides methods

- (void)loadActiveRides {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/getMyActiveRides"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.refreshControl endRefreshing];
        
        NSError *error;
        NSArray<Ride *> *rides = [MTLJSONAdapter modelsOfClass:Ride.class fromJSONArray:responseObject error:&error];
        if (error) {
            NSLog(@"Error parsing active rides. %@", error.localizedDescription);
            [self loadingFailedWithOperation:operation error:error];
            return;
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        self.rides = [rides sortedArrayUsingDescriptors:@[sortDescriptor]];

        [self.tableView reloadData];
        
        if (self.rides.count > 0) {
            self.tableView.backgroundView = nil;
            
            // Initialise chats
            for (Ride *ride in self.rides) {
                // If chat doesn't exist in store, create it and subscribe to it
                Chat *chat = [ChatStore chatForRide:ride];
                if (!chat) {
                    chat = [[Chat alloc] initWithRide:ride];
                    [ChatStore setChat:chat forRide:ride];
                }
                if (!chat.subscribed) {
                    [chat subscribe];
                }
            }
        }
        else {
            self.tableView.backgroundView = self.emptyTableLabel;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        [self loadingFailedWithOperation:operation error:error];
    }];
}


#pragma mark - Table methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RideCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    int unreadCount = 0;
    Ride *ride = self.filteredRides[indexPath.row];
    NSNumber *rideID = @(ride.rideID);
    for (Notification *caronaeNotification in self.unreadNotifications) {
        if ([caronaeNotification.rideID isEqualToNumber:rideID]) {
            ++unreadCount;
        }
    }
    
    cell.badgeCount = unreadCount;
    
    return cell;
}

@end
