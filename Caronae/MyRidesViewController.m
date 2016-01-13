#import "MyRidesViewController.h"
#import "Ride.h"
#import "CaronaeRideCell.h"
#import "RideViewController.h"

@interface MyRidesViewController () <RideDelegate>
@property (nonatomic) NSArray *rides;
@property (nonatomic) Ride *selectedRide;
@property (nonatomic) NSDictionary *user;
@end

@implementation MyRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"CaronaeRideCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"Ride Cell"];
    
    self.tableView.rowHeight = 85.0f;
    
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
            [rides addObject:ride];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        _rides = [rides sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
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
    
    NSInteger deletedIndex = [_rides indexOfObject:ride];
    if (deletedIndex == NSNotFound) {
        NSLog(@"Error: ride to be deleted was not found in user's rides");
        return;
    }

    [self updateRides];
}


#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rides.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CaronaeRideCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Ride Cell" forIndexPath:indexPath];
    
    [cell configureCellWithRide:self.rides[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedRide = self.rides[indexPath.row];
    [self performSegueWithIdentifier:@"ViewRideDetails" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewRideDetails"]) {
        RideViewController *vc = segue.destinationViewController;
        vc.ride = self.selectedRide;
        vc.delegate = self;
    }
}

@end
