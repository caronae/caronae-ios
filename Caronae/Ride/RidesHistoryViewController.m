#import "RidesHistoryViewController.h"
#import "Caronae-Swift.h"

@interface RidesHistoryViewController ()

@end

@implementation RidesHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadRidesHistory];
}

- (void)refreshTable:(id)sender {
    if (self.refreshControl.refreshing) {
        [self loadRidesHistory];
    }
}


#pragma mark - Rides methods

- (void)loadRidesHistory {
    if (self.tableView.backgroundView != nil) {
        self.tableView.backgroundView = self.loadingLabel;
    }
    
    [RideService.instance getRidesHistoryWithSuccess:^(NSArray<Ride *> * _Nonnull rides) {
        [self.refreshControl endRefreshing];
        
        self.rides = rides;
        [self.tableView reloadData];
        
        if (self.rides.count > 0) {
            self.tableView.backgroundView = nil;
        }
        else {
            self.tableView.backgroundView = self.emptyTableLabel;
        }
    } error:^(NSError * _Nullable error) {
        [self.refreshControl endRefreshing];
        // TODO: Handle failed loading
    }];
}

@end
