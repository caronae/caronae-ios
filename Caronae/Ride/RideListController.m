#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <CRToast/CRToast.h>
#import "CaronaeAlertController.h"
#import "RideListController.h"
#import "UIViewController+isVisible.h"
#import "Caronae-Swift.h"

static NSString *const RideListDefaultEmptyMessage = @"Nenhuma carona\nencontrada.";
static NSString *const RideListDefaultLoadingMessage = @"Carregando...";
static NSString *const RideListDefaultErrorMessage = @"Não foi possível\ncarregar as caronas.";

static NSString *const RideListMessageAlternateFontFamily = @"HelveticaNeue-UltraLight";
static CGFloat const RideListMessageFontSize = 25.0f;

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
        self.hidesDirectionControl = NO;
        
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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass(RideCell.class) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"Ride Cell"];
    
    if (self.hidesDirectionControl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.directionControl removeFromSuperview];
        });
    }
    else {
        self.tableView.contentInset = UIEdgeInsetsMake(45.0f, 0.0f, 0.0f, 0.0f);
    }
    
    self.tableView.rowHeight = 85.0f;
    self.tableView.backgroundView = self.loadingLabel;
    
    if (self.historyTable) {
        self.tableView.allowsSelection = NO;
    }
}

- (void)setRides:(NSArray *)rides {
    _rides = rides;
    [self updateFilteredRides];
}

- (void)updateFilteredRides {
    if (_rides) {
        _tableView.backgroundView = ([_rides count] == 0) ? self.emptyTableLabel : nil;
        
        NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:[_rides count]];
        for (Ride *ride in _rides) {
            if (self.hidesDirectionControl || ride.going == self.ridesDirectionGoing) {
                [filtered addObject:ride];
            }
        }
        
        self.filteredRides = filtered;
    } else {
        self.filteredRides = @[];
    }
}

- (void)loadingFailedWithStatusCode:(NSInteger)statusCode andError:(NSError *)error {
    if (self.filteredRides.count == 0) {
        self.tableView.backgroundView = self.errorLabel;
    }
    
    NSLog(@"%@ failed to load rides: %@", NSStringFromClass(self.class), error.localizedDescription);
    
    if (statusCode == 403) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Erro de autorização" message:@"Ocorreu um erro autenticando seu usuário. Sua chave de acesso pode ter sido alterada ou suspensa." handler:^{
            [UserService.instance signOut];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredRides count];
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


#pragma mark - Extra views

// Background view when the table is empty
- (UILabel *)emptyTableLabel {
    if (!_emptyTableLabel) {
        _emptyTableLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _emptyTableLabel.text = self.emptyMessage ? self.emptyMessage : RideListDefaultEmptyMessage;
        _emptyTableLabel.textColor = [UIColor grayColor];
        _emptyTableLabel.numberOfLines = 0;
        _emptyTableLabel.textAlignment = NSTextAlignmentCenter;
        if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
            _emptyTableLabel.font = [UIFont systemFontOfSize:RideListMessageFontSize weight:UIFontWeightUltraLight];
        }
        else {
            _emptyTableLabel.font = [UIFont fontWithName:RideListMessageAlternateFontFamily size:RideListMessageFontSize];
        }
        [_emptyTableLabel sizeToFit];
    }
    return _emptyTableLabel;
}

// Background view when an error occurs
- (UILabel *)errorLabel {
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _errorLabel.text = RideListDefaultErrorMessage;
        _errorLabel.textColor = [UIColor grayColor];
        _errorLabel.numberOfLines = 0;
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
            _errorLabel.font = [UIFont systemFontOfSize:RideListMessageFontSize weight:UIFontWeightUltraLight];
        }
        else {
            _errorLabel.font = [UIFont fontWithName:RideListMessageAlternateFontFamily size:RideListMessageFontSize];
        }
        [_errorLabel sizeToFit];
    }
    return _errorLabel;
}

// Background view when the table is loading
- (UILabel *)loadingLabel {
    if (!_loadingLabel) {
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _loadingLabel.text = RideListDefaultLoadingMessage;
        _loadingLabel.textColor = [UIColor grayColor];
        _loadingLabel.numberOfLines = 0;
        _loadingLabel.textAlignment = NSTextAlignmentCenter;
        if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
            _loadingLabel.font = [UIFont systemFontOfSize:RideListMessageFontSize weight:UIFontWeightUltraLight];
        }
        else {
            _loadingLabel.font = [UIFont fontWithName:RideListMessageAlternateFontFamily size:RideListMessageFontSize];
        }
        [_loadingLabel sizeToFit];
    }
    return _loadingLabel;
}

@end
