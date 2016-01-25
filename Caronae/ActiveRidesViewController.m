#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "CaronaeAlertController.h"
#import "ActiveRidesViewController.h"
#import "CaronaeRideCell.h"
#import "RideViewController.h"
#import "Ride.h"

@interface ActiveRidesViewController ()
@property (nonatomic) NSArray *rides;
@property (nonatomic) Ride *selectedRide;
@property (nonatomic) UILabel *emptyTableLabel;
@property (nonatomic) UILabel *errorLabel;
@property (nonatomic) UILabel *loadingLabel;
@end

@implementation ActiveRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"CaronaeRideCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"Ride Cell"];
    
    self.tableView.rowHeight = 85.0f;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithWhite:0.98f alpha:1.0f];
    self.refreshControl.tintColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    [self.refreshControl addTarget:self
                            action:@selector(refreshTable:)
                  forControlEvents:UIControlEventValueChanged];
    
    // Display a message when the table is empty
    _emptyTableLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _emptyTableLabel.text = @"Você não possui caronas\nativas no momento.";
    _emptyTableLabel.textColor = [UIColor grayColor];
    _emptyTableLabel.numberOfLines = 0;
    _emptyTableLabel.textAlignment = NSTextAlignmentCenter;
    if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        _emptyTableLabel.font = [UIFont systemFontOfSize:25.0f weight:UIFontWeightUltraLight];
    }
    else {
        _emptyTableLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25.0f];
    }
    [_emptyTableLabel sizeToFit];
    
    // Display a message when an error occurs
    _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _errorLabel.text = @"Não foi possível\ncarregar as caronas.";
    _errorLabel.textColor = [UIColor grayColor];
    _errorLabel.numberOfLines = 0;
    _errorLabel.textAlignment = NSTextAlignmentCenter;
    if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        _errorLabel.font = [UIFont systemFontOfSize:25.0f weight:UIFontWeightUltraLight];
    }
    else {
        _errorLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25.0f];
    }
    [_errorLabel sizeToFit];
    
    // Display a message when the table is loading
    _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _loadingLabel.text = @"Carregando...";
    _loadingLabel.textColor = [UIColor grayColor];
    _loadingLabel.numberOfLines = 0;
    _loadingLabel.textAlignment = NSTextAlignmentCenter;
    if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        _loadingLabel.font = [UIFont systemFontOfSize:25.0f weight:UIFontWeightUltraLight];
    }
    else {
        _loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25.0f];
    }
    [_loadingLabel sizeToFit];

    self.tableView.backgroundView = _loadingLabel;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadActiveRides];
}

- (void)refreshTable:(id)sender {
    if (self.refreshControl.refreshing) {
        [self loadActiveRides];
    }
}


#pragma mark - Rides methods

- (void)loadActiveRides {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/getMyActiveRides"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.refreshControl endRefreshing];
        
        NSError *responseError;
        NSArray *rides = [ActiveRidesViewController parseResultsFromResponse:responseObject withError:&responseError];
        if (!responseError) {
            NSLog(@"Active rides returned %lu rides.", (unsigned long)rides.count);
            self.rides = rides;
            if (self.rides.count > 0) {
                self.tableView.backgroundView = nil;
            }
            else {
                self.tableView.backgroundView = _emptyTableLabel;
            }
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        self.tableView.backgroundView = _errorLabel;
        
        if (operation.response.statusCode == 403) {
            [CaronaeAlertController presentOkAlertWithTitle:@"Erro de autorização" message:@"Ocorreu um erro autenticando seu usuário. Seu token pode ter sido suspenso ou expirado." handler:^{
                [CaronaeDefaults signOut];
            }];
        }
        else {
            NSLog(@"Error loading active rides: %@", error.localizedDescription);
        }
    }];
}

+ (NSArray *)parseResultsFromResponse:(id)responseObject withError:(NSError *__autoreleasing *)err {
    // Check if we received an array of the rides
    if ([responseObject isKindOfClass:NSArray.class]) {
        NSMutableArray *rides = [NSMutableArray arrayWithCapacity:((NSArray*)responseObject).count];
        for (NSDictionary *rideDictionary in responseObject) {
            Ride *ride = [[Ride alloc] initWithDictionary:rideDictionary];
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


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewRideDetails"]) {
        RideViewController *vc = segue.destinationViewController;
        vc.ride = self.selectedRide;
    }
}


#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.rides && self.rides.count > 0) ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rides.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CaronaeRideCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Ride Cell" forIndexPath:indexPath];
    
    [cell configureCellWithRide:self.rides[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedRide = self.rides[indexPath.row];
    [self performSegueWithIdentifier:@"ViewRideDetails" sender:self];
}


@end
