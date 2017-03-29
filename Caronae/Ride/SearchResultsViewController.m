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
        searchVC.previouslySelectedSegmentIndex = self.previouslySelectedSegmentIndex;
        searchVC.delegate = self;
    }
}

-(IBAction)showResultsUnwind:(UIStoryboardSegue *)segue {
}


#pragma mark - Search methods

- (void)searchedForRideWithParameters:(FilterParameters*)parameters {
    [SVProgressHUD show];
    if (self.tableView.backgroundView != nil) {
        self.tableView.backgroundView = self.loadingLabel;
    }
    
    [RideService.instance getRidesWithPage:1 filterParameters:parameters success:^(NSArray<Ride *> * _Nonnull rides) {
        self.rides = rides;
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
        
        if (rides.count == 0) {            
            // Hack so that the alert is not presented from the modal search dialog
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                [CaronaeAlertController presentOkAlertWithTitle:@"Nenhuma carona\nencontrada :(" message:@"Você pode ampliar sua pesquisa selecionando vários bairros ou escolhendo um horário mais cedo."];
            });
        }

    } error:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self loadingFailedWithError:error];
    }];
}

@end
