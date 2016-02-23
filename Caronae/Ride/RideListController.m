#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <CRToast/CRToast.h>
#import "CaronaeAlertController.h"
#import "RideListController.h"
#import "UIViewController+isVisible.h"

@interface RideListController() <RideDelegate>
@property (nonatomic, readwrite) NSArray<Ride *> *filteredRides;
@end

@implementation RideListController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(RideListController.class)
                                                   owner:self
                                                 options:nil] objectAtIndex:0];
        
        self.historyTable = NO;
        self.ridesDirectionGoing = YES;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([self respondsToSelector:@selector(refreshTable:)]) {
            self.refreshControl = [[UIRefreshControl alloc] init];
            self.refreshControl.tintColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
            [self.refreshControl addTarget:self
                                    action:@selector(refreshTable:)
                          forControlEvents:UIControlEventValueChanged];
            [self.tableView addSubview:self.refreshControl];
        }
#pragma clang diagnostic pop
        
        // Background view when the table is empty
        _emptyTableLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _emptyTableLabel.text = @"Nenhuma carona\nencontrada.";
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
        
        // Background view when an error occurs
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
        
        // Background view when the table is loading
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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass(RideCell.class) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"Ride Cell"];
    
    self.tableView.rowHeight = 85.0f;
    self.tableView.contentInset = UIEdgeInsetsMake(45.0f, 0.0f, 0.0f, 0.0f);
    
    self.tableView.backgroundView = self.loadingLabel;
    
    if (self.historyTable) {
        self.tableView.allowsSelection = NO;
    }
}

+ (NSArray *)filterRides:(NSArray *)rides withDirectionGoing:(BOOL)going {
    NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:rides.count];
    
    for (Ride *ride in rides) {
        if (ride.going == going) {
            [filtered addObject:ride];
        }
    }
    
    return filtered;
}

- (void)setRides:(NSArray *)rides {
    _rides = rides;
    if (_rides) {
        self.filteredRides = [RideListController filterRides:_rides withDirectionGoing:self.ridesDirectionGoing];
    }
}

- (void)loadingFailedWithOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    if (self.filteredRides.count == 0) {
        self.tableView.backgroundView = self.errorLabel;
    }
    
    NSLog(@"%@ failed to load rides: %@", NSStringFromClass(self.class), error.localizedDescription);
    
    if (operation && operation.response.statusCode == 403) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Erro de autorização" message:@"Ocorreu um erro autenticando seu usuário. Seu token pode ter sido suspenso ou expirado." handler:^{
            [CaronaeDefaults signOut];
        }];
        return;
    }
    
    if (![self isVisible]) return;
    
    if (![AFNetworkReachabilityManager sharedManager].isReachable) {
        [CRToastManager showNotificationWithOptions:@{
                                                      kCRToastTextKey: @"Sem conexão com a internet",
                                                      kCRToastBackgroundColorKey: [UIColor redColor],
                                                      }
                                    completionBlock:nil];

    }
    else {
        NSString *errorAlertTitle = @"Algo deu errado.";
        NSString *errorAlertMessage = @"Não foi possível carregar as caronas. Por favor, tente novamente.";
        [CaronaeAlertController presentOkAlertWithTitle:errorAlertTitle message:errorAlertMessage];
    }
}


#pragma mark - Navigation

- (RideViewController *)rideViewControllerForRide:(Ride *)ride {
    RideViewController *rideVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RideViewController"];
    rideVC.ride = ride;
    rideVC.delegate = self;
    
    return rideVC;
}


#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.filteredRides && self.filteredRides.count > 0) ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.filteredRides && self.filteredRides.count > 0) ? self.filteredRides.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RideCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Ride Cell" forIndexPath:indexPath];
    
    if (!self.historyTable) {
        [cell configureCellWithRide:self.filteredRides[indexPath.row]];
    }
    else {
        [cell configureHistoryCellWithRide:self.filteredRides[indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.historyTable) {
        Ride *ride = self.filteredRides[indexPath.row];
        RideViewController *rideVC = [self rideViewControllerForRide:ride];
        
        [self.navigationController pushViewController:rideVC animated:YES];
    }
}


#pragma mark - IBActions

- (IBAction)didChangeDirection:(UISegmentedControl *)sender {
    self.ridesDirectionGoing = (sender.selectedSegmentIndex == 0);
    [self setRides:self.rides];
    [self.tableView reloadData];
}

@end
