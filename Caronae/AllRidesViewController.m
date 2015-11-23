#import "AllRidesViewController.h"

@interface AllRidesViewController ()

@end

@implementation AllRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 400.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
}


#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Ride Cell" forIndexPath:indexPath];
    
    [self configureOpportunityCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureOpportunityCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

}


@end
