#import <AFNetworking/AFNetworking.h>
#import "CaronaeConstants.h"
#import "AllRidesViewController.h"
#import "CaronaeRideTableViewCell.h"
#import "SearchRideViewController.h"

@interface AllRidesViewController () <SeachRideDelegate, CaronaeRideCellDelegate>
@property (nonatomic) NSArray *rides;
@end

@implementation AllRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SearchRide"]) {
        UINavigationController *searchNavController = segue.destinationViewController;
        SearchRideViewController *searchVC = searchNavController.viewControllers.firstObject;
        searchVC.delegate = self;
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
    NSString *userToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:userToken forHTTPHeaderField:@"token"];
    
//    [self showLoadingHUD:YES];
    
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/listFiltered"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [self showLoadingHUD:NO];
        
        NSLog(@"Search results are back.");
        
        NSError *responseError;
        NSArray *rides = [AllRidesViewController parseSearchResultsFromResponse:responseObject withError:&responseError];
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
        return responseObject;
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

- (void)tappedJoinRide:(CaronaeRideTableViewCell *)cell {
    NSDictionary *ride = cell.ride;
    NSLog(@"Requesting to join ride %@", ride[@"rideId"]);
    NSDictionary *params = @{@"rideId": ride[@"rideId"]};
    
    NSString *userToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:userToken forHTTPHeaderField:@"token"];
    
    cell.requestRideButton.enabled = NO;
    
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/requestJoin"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Done requesting ride.");
        [cell.requestRideButton setTitle:@"CARONA SOLICITADA" forState:UIControlStateNormal];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
        cell.requestRideButton.enabled = YES;
    }];

}

#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rides.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CaronaeRideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Ride Cell" forIndexPath:indexPath];
    
    [cell configureCellWithRide:self.rides[indexPath.row] canJoin:YES];
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
