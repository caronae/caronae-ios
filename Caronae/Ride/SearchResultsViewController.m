#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "SearchRideViewController.h"
#import "Ride.h"
#import "RideViewController.h"
#import "SearchResultsViewController.h"

@interface SearchResultsViewController () <SearchRideDelegate>

@end

@implementation SearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.searchParams) {
        [self searchForRidesWithParameters:self.searchParams];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SearchRide"]) {
        UINavigationController *searchNavController = segue.destinationViewController;
        SearchRideViewController *searchVC = searchNavController.viewControllers.firstObject;
        searchVC.delegate = self;
    }
}


#pragma mark - Search methods

- (void)searchedForRideWithCenter:(NSString *)center andNeighborhoods:(NSArray *)neighborhoods onDate:(NSDate *)date going:(BOOL)going {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";
    NSString *timeString = [timeFormatter stringFromDate:date];
    
    self.searchParams = @{@"center": center,
                          @"location": [neighborhoods componentsJoinedByString:@", "],
                          @"date": dateString,
                          @"time": timeString,
                          @"go": @(going)
                          };
    
    [self searchForRidesWithParameters:self.searchParams];
}

- (void)searchForRidesWithParameters:(NSDictionary *)params {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [SVProgressHUD show];
    
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/listFiltered"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        
        NSLog(@"Search results are back.");
        
        NSError *responseError;
        NSArray *rides = [SearchResultsViewController parseSearchResultsFromResponse:responseObject withError:&responseError];
        if (!responseError) {
            NSLog(@"Search returned %lu rides.", (unsigned long)rides.count);
            
            self.rides = rides;
            [self.tableView reloadData];
            if (rides.count > 0) {
                self.tableView.backgroundView = nil;
            }
            else {
                self.tableView.backgroundView = self.emptyTableLabel;
            }
        }
        else {
            self.tableView.backgroundView = self.errorLabel;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        self.tableView.backgroundView = self.errorLabel;
        NSLog(@"Error searching for ride: %@", error.localizedDescription);
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

@end
