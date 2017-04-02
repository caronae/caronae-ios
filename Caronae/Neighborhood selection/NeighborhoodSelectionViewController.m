#import "NeighborhoodSelectionViewController.h"
#import "ZoneCell.h"

@interface NeighborhoodSelectionViewController ()

@property (nonatomic) UIBarButtonItem *doneButton;
@property (nonatomic) NSArray *neighborhoods;

@end

@implementation NeighborhoodSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.selectedZone;
    self.neighborhoods = CaronaeConstants.defaults.neighborhoods[self.selectedZone];
    
    if (self.neighborhoodSelectionType == NeighborhoodSelectionMany) {
        self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Sel. todos" style:UIBarButtonItemStyleDone target:self action:@selector(finishSelection)];
        self.navigationItem.rightBarButtonItem = self.doneButton;
        self.tableView.allowsMultipleSelection = YES;
    }
}

- (void)finishSelection {
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    NSArray *selectedIndexPaths = self.tableView.indexPathsForSelectedRows;
    NSArray *selections;
    
    if (selectedIndexPaths.count == 0 || selectedIndexPaths.count == self.neighborhoods.count) {
        selections = @[self.selectedZone];
    } else {
        NSMutableArray *selectedNeighborhoods = [NSMutableArray arrayWithCapacity:selectedIndexPaths.count];
        for (NSIndexPath *indexPath in selectedIndexPaths) {
            [selectedNeighborhoods addObject:self.neighborhoods[indexPath.row]];
        }
        selections = selectedNeighborhoods;
    }
    
    [self.delegate hasSelectedNeighborhoods:selections];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.neighborhoods.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZoneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Zone Cell"];
    
    NSString *neighborhood = self.neighborhoods[indexPath.row];
    UIColor *cellColor = [CaronaeConstants colorForZone:self.selectedZone];
    
    [cell setupCellWithNeighborhood:neighborhood color:cellColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.neighborhoodSelectionType == NeighborhoodSelectionOne) {
        [self finishSelection];
        return;
    }
    
    if ([self.neighborhoods[indexPath.row] isEqualToString:CaronaeAllNeighborhoodsText]) {
        [self finishSelection];
        return;
    }
    
    [self updateFinishButton];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateFinishButton];
}

- (void)updateFinishButton {
    self.doneButton.title = (self.tableView.indexPathsForSelectedRows.count > 0) ? @"OK" : @"Sel. todos";
}

@end
