@import CoreData;
@import SVProgressHUD;

#import "ActiveRidesViewController.h"
#import "Chat.h"
#import "ChatStore.h"
#import "Notification+CoreDataProperties.h"
#import "NotificationStore.h"
#import "Caronae-Swift.h"

@interface ActiveRidesViewController () <UITableViewDelegate>
@property (nonatomic) NSArray<Notification *> *unreadNotifications;
@end

@implementation ActiveRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
    
    [self updateUnreadNotifications];
    [self loadActiveRides];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadNotifications) name:CaronaeDidUpdateNotifications object:nil];
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
    
    [self.tableView reloadData];
}


#pragma mark - Navigation

- (void)openChatForRideWithID:(NSNumber *)rideID {
    Ride *ride;
    
    // Find ride
    for (Ride *r in self.rides) {
        if ([rideID isEqualToNumber:@(r.id)]) {
            ride = r;
            break;
        }
    }
    
    if (ride) {
        RideViewController *rideVC = [RideViewController rideViewControllerForRide:ride];
        rideVC.shouldOpenChatWindow = YES;
        
        [self.navigationController pushViewController:rideVC animated:YES];
    }
}


#pragma mark - Rides methods

- (void)loadActiveRides {
    [RideService.instance getActiveRidesWithSuccess:^(NSArray<Ride *> * _Nonnull rides) {
        [self.refreshControl endRefreshing];
        self.rides = rides;
        
        [self.tableView reloadData];
        
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

    } error:^(NSError * _Nullable error) {
        [self.refreshControl endRefreshing];
        [self loadingFailedWithError:error];
    }];
}


#pragma mark - Table methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RideCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    int unreadCount = 0;
    Ride *ride = self.filteredRides[indexPath.row];
    NSNumber *rideID = @(ride.id);
    for (Notification *caronaeNotification in self.unreadNotifications) {
        if ([caronaeNotification.rideID isEqualToNumber:rideID]) {
            ++unreadCount;
        }
    }
    
    cell.badgeCount = unreadCount;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UILabel *titleMessage = [[UILabel alloc] init];
    titleMessage.text = @"Se você é motorista de alguma carona, não\n esqueça de concluí-la após seu término. :)";
    titleMessage.numberOfLines = 0;
    titleMessage.backgroundColor = [UIColor whiteColor];
    titleMessage.font = [UIFont systemFontOfSize:10];
    titleMessage.textColor = [UIColor lightGrayColor];
    titleMessage.textAlignment = NSTextAlignmentCenter;
    return titleMessage;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40.0f;
}


@end
