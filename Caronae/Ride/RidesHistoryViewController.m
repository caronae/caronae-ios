#import <AFNetworking/AFNetworking.h>
#import "RidesHistoryViewController.h"

@interface RidesHistoryViewController ()

@end

@implementation RidesHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadRidesHistory];
}


#pragma mark - Rides methods

- (void)loadRidesHistory {
    if (self.tableView.backgroundView != nil) {
        self.tableView.backgroundView = self.loadingLabel;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/getRidesHistory"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSArray<Ride *> *rides = [MTLJSONAdapter modelsOfClass:Ride.class fromJSONArray:responseObject error:&error];
        if (error) {
            NSLog(@"Error parsing rides history. %@", error.localizedDescription);
            [self loadingFailedWithOperation:operation error:error];
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self loadingFailedWithOperation:operation error:error];
    }];
}

@end
