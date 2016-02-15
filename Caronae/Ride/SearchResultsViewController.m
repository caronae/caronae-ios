#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "CaronaeAlertController.h"
#import "Ride.h"
#import "RideViewController.h"
#import "SearchResultsViewController.h"
#import "SearchRideViewController.h"

@interface SearchResultsViewController () <SearchRideDelegate>
@end

@implementation SearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    NSDictionary *searchParams = @{@"center": center,
                          @"location": [neighborhoods componentsJoinedByString:@", "],
                          @"date": dateString,
                          @"time": timeString,
                          @"go": @(going)
                          };
    
    [self searchForRidesWithParameters:searchParams];
}

- (void)searchForRidesWithParameters:(NSDictionary *)params {
    [SVProgressHUD show];
    if (self.tableView.backgroundView != nil) {
        self.tableView.backgroundView = self.loadingLabel;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/listFiltered"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        
        NSError *error;
        NSArray<Ride *> *rides = [MTLJSONAdapter modelsOfClass:Ride.class fromJSONArray:responseObject error:&error];
        if (error) {
            NSLog(@"Error parsing all rides. %@", error.localizedDescription);
            self.tableView.backgroundView = self.errorLabel;
            return;
        }
                
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        self.rides = [rides sortedArrayUsingDescriptors:@[sortDescriptor]];

        [self.tableView reloadData];
        
        if (rides.count > 0) {
            self.tableView.backgroundView = nil;
        }
        else {
            self.tableView.backgroundView = self.emptyTableLabel;
            
            // Hack so that the alert is not presented from the modal search dialog
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                [CaronaeAlertController presentOkAlertWithTitle:@"Nenhuma carona encontrada :(" message:@"Você pode ampliar sua pesquisa selecionando vários bairros ou escolhendo um horário mais cedo."];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];      
        // Hack so that the alert is not presented from the modal search dialog
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [self loadingFailedWithOperation:operation error:error];
        });
    }];
}

@end
