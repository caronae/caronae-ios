#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "CaronaeAlertController.h"
#import "SearchResultsViewController.h"
#import "SearchRideViewController.h"
#import "Caronae-Swift.h"

@interface SearchResultsViewController () <SearchRideDelegate>
@end

@implementation SearchResultsViewController

- (void)viewDidLoad {
    self.hidesDirectionControl = YES;
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
    [SVProgressHUD show];
    if (self.tableView.backgroundView != nil) {
        self.tableView.backgroundView = self.loadingLabel;
    }
    
    [RideService.instance searchRidesWithCenter:center neighborhoods:neighborhoods date:date going:going success:^(NSArray<Ride *> * _Nonnull rides) {
        self.rides = rides;
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
        
        if (rides.count > 0) {
            self.tableView.backgroundView = nil;
        }
        else {
            self.tableView.backgroundView = self.emptyTableLabel;
            
            // Hack so that the alert is not presented from the modal search dialog
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                [CaronaeAlertController presentOkAlertWithTitle:@"Nenhuma carona\nencontrada :(" message:@"Você pode ampliar sua pesquisa selecionando vários bairros ou escolhendo um horário mais cedo."];
            });
        }

    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        // TODO: Handle loading failed
    }];
}

@end
