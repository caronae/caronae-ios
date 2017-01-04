#import <SVProgressHUD/SVProgressHUD.h>
#import "AllRidesViewController.h"
#import "EditProfileViewController.h"
#import "SearchResultsViewController.h"
#import "SearchRideViewController.h"
#import "Caronae-Swift.h"

@interface AllRidesViewController () <SearchRideDelegate>
@property (nonatomic) NSDictionary *searchParams;
@property (nonatomic) UIView *tableFooter;
@end

@implementation AllRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([UserController sharedInstance].user.isProfileIncomplete) {
        [self performSelector:@selector(presentFinishProfileScreen) withObject:nil afterDelay:0.0];
    }
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadAllRides];
}

- (UIView *)tableFooter {
    if (!_tableFooter) {
        UILabel *tableFooter = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
        tableFooter.text = @"Quer encontrar mais caronas? Use a pesquisa! 🔍";
        tableFooter.numberOfLines = 0;
        tableFooter.backgroundColor = [UIColor whiteColor];
        tableFooter.font = [UIFont systemFontOfSize:10];
        tableFooter.textColor = [UIColor lightGrayColor];
        tableFooter.textAlignment = NSTextAlignmentCenter;
        _tableFooter = tableFooter;
    }
    return _tableFooter;
}

- (void)refreshTable:(id)sender {
    if (self.refreshControl.refreshing) {
        [self loadAllRides];
    }
}

- (void)presentFinishProfileScreen {
    UINavigationController *editProfileNavController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EditProfileNavigationController"];;
    EditProfileViewController *vc = editProfileNavController.viewControllers.firstObject;
    vc.completeProfileMode = YES;
    [self presentViewController:editProfileNavController animated:YES completion:nil];
}


#pragma mark - Rides methods

- (void)loadAllRides {
    if (self.tableView.backgroundView != nil) {
        self.tableView.backgroundView = self.loadingLabel;
    }
    
    [CaronaeAPIHTTPSessionManager.instance GET:@"/ride/all" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [self.refreshControl endRefreshing];
        
        NSError *error;
        NSArray<Ride *> *rides = [MTLJSONAdapter modelsOfClass:Ride.class fromJSONArray:responseObject error:&error];
        if (error) {
            NSLog(@"Error parsing all rides. %@", error.localizedDescription);
            NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
            [self loadingFailedWithStatusCode:response.statusCode andError:error];
            return;
        }
        
        // Skip rides in the past
        NSMutableArray<Ride *> *futureRides = [NSMutableArray arrayWithCapacity:rides.count];
        for (Ride *ride in rides) {
            if ([ride.date compare:NSDate.date] != NSOrderedAscending) {
                [futureRides addObject:ride];
            }
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        self.rides = [futureRides sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        [self.tableView reloadData];
        
        if (self.rides.count > 0) {
            self.tableView.backgroundView = nil;
            self.tableView.tableFooterView = self.tableFooter;
        }
        else {
            self.tableView.backgroundView = self.emptyTableLabel;
            self.tableView.tableFooterView = nil;
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.refreshControl endRefreshing];
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
        [self loadingFailedWithStatusCode:response.statusCode andError:error];
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SearchRide"]) {
        UINavigationController *searchNavController = segue.destinationViewController;
        SearchRideViewController *searchVC = searchNavController.viewControllers.firstObject;
        searchVC.previouslySelectedSegmentIndex = self.directionControl.selectedSegmentIndex;
        searchVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"ViewSearchResults"]) {
        SearchResultsViewController *vc = segue.destinationViewController;
        [vc searchForRidesWithParameters:self.searchParams];
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
    
    [self performSegueWithIdentifier:@"ViewSearchResults" sender:self];
}


@end
