#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "AllRidesViewController.h"
#import "CaronaeAlertController.h"
#import "EditProfileViewController.h"
#import "Ride.h"
#import "RideCell.h"
#import "RideViewController.h"
#import "SearchResultsViewController.h"
#import "SearchRideViewController.h"

@interface AllRidesViewController () <SearchRideDelegate>
@property (nonatomic) NSDictionary *searchParams;
@end

@implementation AllRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([CaronaeDefaults userProfileIsIncomplete]) {
        [self performSelector:@selector(presentFinishProfileScreen) withObject:nil afterDelay:0.0];
    }
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
    
    [self loadAllRides];
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/all"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.refreshControl endRefreshing];
        
        NSError *error;
        NSArray<Ride *> *rides = [MTLJSONAdapter modelsOfClass:Ride.class fromJSONArray:responseObject error:&error];
        if (error) {
            NSLog(@"Error parsing all rides. %@", error.localizedDescription);
            return;
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        self.rides = [rides sortedArrayUsingDescriptors:@[sortDescriptor]];

        [self.tableView reloadData];
        
        if (self.rides.count > 0) {
            self.tableView.backgroundView = nil;
        }
        else {
            self.tableView.backgroundView = self.emptyTableLabel;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        
        self.tableView.backgroundView = self.errorLabel;
        
        if (operation.response.statusCode == 403) {
            [CaronaeAlertController presentOkAlertWithTitle:@"Erro de autorização" message:@"Ocorreu um erro autenticando seu usuário. Seu token pode ter sido suspenso ou expirado." handler:^{
                [CaronaeDefaults signOut];
            }];
        }
        else {
            NSLog(@"Error loading all rides: %@", error.localizedDescription);
        }
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SearchRide"]) {
        UINavigationController *searchNavController = segue.destinationViewController;
        SearchRideViewController *searchVC = searchNavController.viewControllers.firstObject;
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
