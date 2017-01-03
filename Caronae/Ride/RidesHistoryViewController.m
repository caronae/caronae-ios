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
    
    [CaronaeAPIHTTPSessionManager.instance GET:@"/ride/getRidesHistory" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [self.refreshControl endRefreshing];

        NSError *error;
        // TODO: deserialize rides
        NSArray<Ride *> *rides = nil;
        if (error) {
            NSLog(@"Error parsing rides history. %@", error.localizedDescription);
            NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
            [self loadingFailedWithStatusCode:response.statusCode andError:error];
            return;
        }

        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        self.rides = [rides sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        [self.tableView reloadData];
        
        if (self.rides.count > 0) {
            self.tableView.backgroundView = nil;
        }
        else {
            self.tableView.backgroundView = self.emptyTableLabel;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.refreshControl endRefreshing];
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
        [self loadingFailedWithStatusCode:response.statusCode andError:error];
    }];
}

@end
