#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "RidesHistoryViewController.h"
#import "CaronaeRideCell.h"
#import "RideViewController.h"
#import "Ride.h"

@interface RidesHistoryViewController ()
@property (nonatomic) NSArray *rides;
@property (nonatomic) Ride *selectedRide;
@end

@implementation RidesHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"CaronaeRideCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"Ride Cell"];
    
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self loadRidesHistory];
}


#pragma mark - Rides methods

- (void)loadRidesHistory {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/getRidesHistory"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *responseError;
        NSArray *rides = [RidesHistoryViewController parseResultsFromResponse:responseObject withError:&responseError];
        if (!responseError) {
            NSLog(@"Rides history returned %lu rides.", (unsigned long)rides.count);
            self.rides = rides;
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
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


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewRideDetails"]) {
        RideViewController *vc = segue.destinationViewController;
        vc.ride = self.selectedRide;
    }
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
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

@end
