#import "CaronaeRideListController.h"
#import "CaronaeRideCell.h"
#import "RideViewController.h"

@interface CaronaeRideListController()<RideDelegate>

@end

@implementation CaronaeRideListController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.view = [[[NSBundle mainBundle] loadNibNamed:@"CaronaeRideListController"
                                                   owner:self
                                                 options:nil] objectAtIndex:0];
        
        self.historyTable = NO;
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.tintColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        [self.refreshControl addTarget:self
                                action:@selector(refreshTable:)
                      forControlEvents:UIControlEventValueChanged];
        
        
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
    
    UINib *cellNib = [UINib nibWithNibName:@"CaronaeRideCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"Ride Cell"];
    
    self.tableView.rowHeight = 85.0f;
    self.tableView.contentInset = UIEdgeInsetsMake(45.0f, 0.0f, 0.0f, 0.0f);
    
    if (self.refreshControl) {
        [self.tableView addSubview:self.refreshControl];
    }
    
    self.tableView.backgroundView = self.loadingLabel;
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
    
    if (!self.historyTable) {
        [cell configureCellWithRide:self.rides[indexPath.row]];
    }
    else {
        [cell configureHistoryCellWithRide:self.rides[indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.historyTable) {
        self.selectedRide = self.rides[indexPath.row];
        
        RideViewController *rideVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RideViewController"];
        rideVC.ride = self.selectedRide;
        rideVC.delegate = self;
        
        [self.navigationController pushViewController:rideVC animated:YES];
    }
}

@end
