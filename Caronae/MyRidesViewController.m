#import "MyRidesViewController.h"
#import "Ride.h"
#import "CaronaeRideCell.h"
#import "RideViewController.h"
#import "ChatStore.h"

@interface MyRidesViewController ()

@property (nonatomic) NSDictionary *user;

@end

@implementation MyRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
        
    self.user = [CaronaeDefaults defaults].user;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:CaronaeUserRidesUpdatedNotification object:nil];
    
    [self updateRides];
}

- (void)didReceiveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:CaronaeUserRidesUpdatedNotification]) {
        [self updateRides];
    }
}


#pragma mark - Ride methods

- (void)updateRides {
    // Run in secondary thread so it won't affect UI
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *rideArchive = [[NSUserDefaults standardUserDefaults] objectForKey:@"userCreatedRides"];
        NSMutableArray *rides = [[NSMutableArray alloc] initWithCapacity:rideArchive.count];
        for (id rideDictionary in rideArchive) {
            Ride *ride = [[Ride alloc] initWithDictionary:rideDictionary];
            
            // Skip rides in the past
            if ([ride.date compare:[NSDate date]] == NSOrderedAscending) {
                continue;
            }
            
            ride.driver = self.user;
            
            // Checking if subscribed to my rides after delay to ensure GCM is connected
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                if (![ChatStore chatForRide:ride]) {
                    Chat *chat = [[Chat alloc] initWithRide:ride];
                    if (!chat.subscribed) {
                        [chat subscribe];
                    }
                    [ChatStore setChat:chat forRide:ride];
                }
            });

            [rides addObject:ride];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        self.rides = [rides sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        if (self.rides.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tableView.backgroundView = nil;
                [self.tableView reloadData];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tableView.backgroundView = self.emptyTableLabel;
            });
        }

    });
}

- (void)didDeleteRide:(Ride *)ride {
    NSLog(@"User has deleted ride with id %ld", ride.rideID);
    
    // Find and delete ride from persistent store
    NSMutableArray *newRides = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userCreatedRides"] mutableCopy];
    for (NSDictionary *r in newRides) {
        if ([r[@"rideId"] longValue] == ride.rideID || [r[@"id"] longValue] == ride.rideID) {
            [newRides removeObject:r];
            break;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:newRides forKey:@"userCreatedRides"];
    
    if (![self.rides containsObject:ride]) {
        NSLog(@"Error: ride to be deleted was not found in user's rides");
        return;
    }

    [self updateRides];
}

@end
