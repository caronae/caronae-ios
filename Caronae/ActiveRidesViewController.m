#import <AFNetworking/AFNetworking.h>
#import "ActiveRidesViewController.h"
#import "CaronaeRideCell.h"
#import "SearchRideViewController.h"
#import "Ride.h"
#import "RideViewController.h"

@interface ActiveRidesViewController () <SeachRideDelegate>
@property (nonatomic) NSArray *rides;
@property (nonatomic) Ride *selectedRide;
@end

@implementation ActiveRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"CaronaeRideCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"Ride Cell"];
    
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
    
    [self loadActiveRides];
}


#pragma mark - Active rides methods

- (void)loadActiveRides {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    //    [self showLoadingHUD:YES];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/getMyActiveRides"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        [self showLoadingHUD:NO];
        
        NSLog(@"Active rides results are back.");
        
        NSError *responseError;
//        NSArray *rides = [AllRidesViewController parseSearchResultsFromResponse:responseObject withError:&responseError];
        NSArray *rides = responseObject;
        if (!responseError) {
            NSLog(@"Search returned %lu rides.", (unsigned long)rides.count);
            self.rides = rides;
            [self.tableView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [self showLoadingHUD:NO];
        NSLog(@"Error: %@", error.description);
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SearchRide"]) {
        UINavigationController *searchNavController = segue.destinationViewController;
        SearchRideViewController *searchVC = searchNavController.viewControllers.firstObject;
        searchVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"ViewRideDetails"]) {
        RideViewController *vc = segue.destinationViewController;
        vc.ride = self.selectedRide;
    }
}


#pragma mark - Search methods

- (void)searchedForRideWithCenter:(NSString *)center andNeighborhood:(NSString *)neighborhood onDate:(NSDate *)date going:(BOOL)going {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";
    NSString *timeString = [timeFormatter stringFromDate:date];
    
    NSDictionary *searchParams = @{@"center": center,
                                   @"location": neighborhood,
                                   @"date": dateString,
                                   @"time": timeString,
                                   @"go": @(going)
                                   };
    
    [self searchForRidesWithParameters:searchParams];
}

- (void)searchForRidesWithParameters:(NSDictionary *)params {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
//    [self showLoadingHUD:YES];
    
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/listFiltered"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [self showLoadingHUD:NO];
        
        NSLog(@"Search results are back.");
        
        NSError *responseError;
        NSArray *rides = [ActiveRidesViewController parseSearchResultsFromResponse:responseObject withError:&responseError];
        if (!responseError) {
            NSLog(@"Search returned %lu rides.", (unsigned long)rides.count);
            self.rides = rides;
            [self.tableView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self showLoadingHUD:NO];
        NSLog(@"Error: %@", error.description);
    }];

}

+ (NSArray *)parseSearchResultsFromResponse:(id)responseObject withError:(NSError *__autoreleasing *)err {
    // Check if we received an array of the rides
    if ([responseObject isKindOfClass:NSArray.class]) {
        NSMutableArray *rides = [NSMutableArray arrayWithCapacity:((NSArray*)responseObject).count];
        for (NSDictionary *result in responseObject) {
            Ride *ride = [[Ride alloc] initWithDictionary:result];
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


@end
