#import "ZoneCell.h"
#import "ZoneSelectionViewController.h"
#import "ZoneSelectionInputViewController.h"

@interface ZoneSelectionViewController ()
@property (nonatomic) NSArray *places;
@property (nonatomic) UIBarButtonItem *doneButton;
@end

@implementation ZoneSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.type == ZoneSelectionZone) {
        self.title = @"Zonas";
        if (self.neighborhoodSelectionType == NeighborhoodSelectionMany) {
            self.places = [@[CaronaeAllNeighborhoodsText] arrayByAddingObjectsFromArray:[CaronaeConstants defaults].zones];
        } else {
            self.places = [CaronaeConstants defaults].zones;
        }
    }
    else {
        self.title = self.selectedZone;
        self.places = [CaronaeConstants defaults].neighborhoods[self.selectedZone];
        
        if (self.neighborhoodSelectionType == NeighborhoodSelectionMany) {
            self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Sel. todos" style:UIBarButtonItemStyleDone target:self action:@selector(finishSelection)];
            self.navigationItem.rightBarButtonItem = self.doneButton;
            self.tableView.allowsMultipleSelection = YES;
        }
    }
}

- (void)finishSelection {
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    if (self.neighborhoodSelectionType == NeighborhoodSelectionMany && [self.delegate respondsToSelector:@selector(hasSelectedNeighborhoods:inZone:)]) {
        NSArray *selectedIndexPaths = self.tableView.indexPathsForSelectedRows;
        
        NSArray *selections;
        if (selectedIndexPaths.count == 0) {
            selections = @[self.selectedZone];
        } else {
            if (selectedIndexPaths.count == self.places.count) {
                selections = @[self.selectedZone];
            } else {
                NSMutableArray *selectedNeighborhoods = [NSMutableArray arrayWithCapacity:selectedIndexPaths.count];
                for (NSIndexPath *indexPath in selectedIndexPaths) {
                    [selectedNeighborhoods addObject:self.places[indexPath.row]];
                }
                selections = selectedNeighborhoods;
            }
        }

        [self.delegate hasSelectedNeighborhoods:selections inZone:self.selectedZone];
    }
    
    else if (self.neighborhoodSelectionType == NeighborhoodSelectionOne && [self.delegate respondsToSelector:@selector(hasSelectedNeighborhood:inZone:)]) {
        NSString *selection = self.places[self.tableView.indexPathForSelectedRow.row];
        [self.delegate hasSelectedNeighborhood:selection inZone:self.selectedZone];
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZoneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Zone Cell"];
    
    NSString *zone = self.places[indexPath.row];
    
    UIColor *cellColor;
    if (self.type == ZoneSelectionZone) {
        cellColor = [CaronaeConstants colorForZone:zone];
    } else {
        cellColor = [CaronaeConstants colorForZone:self.selectedZone];
    }
    
    [cell setupCellWithTitle:zone color:cellColor type:self.type];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == ZoneSelectionNeighborhood && self.neighborhoodSelectionType == NeighborhoodSelectionOne) {
        [self finishSelection];
        return;
    }
    
    if ([self.places[indexPath.row] isEqualToString:CaronaeAllNeighborhoodsText]) {
        self.selectedZone = @"";
        [self finishSelection];
        return;
    }
    
    if (self.type == ZoneSelectionZone) {
        if ([self.places[indexPath.row] isEqualToString:@"Outra"]) {
            self.selectedZone = @"Outros";
            if (self.neighborhoodSelectionType == NeighborhoodSelectionOne) {
                [self performSegueWithIdentifier:@"OtherNeighborhood" sender:self];
            } else {
                [self finishSelection];
            }
            
            return;
        }
        
        
        self.selectedZone = self.places[indexPath.row];
        [self performSegueWithIdentifier:@"ViewNeighborhoods" sender:self];

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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewNeighborhoods"]) {
        ZoneSelectionViewController *vc = segue.destinationViewController;
        vc.type = ZoneSelectionNeighborhood;
        vc.neighborhoodSelectionType = self.neighborhoodSelectionType;
        vc.selectedZone = self.selectedZone;
        vc.delegate = self.delegate;
    }
    else if ([segue.identifier isEqualToString:@"OtherNeighborhood"]) {
        ZoneSelectionInputViewController *vc = segue.destinationViewController;
        vc.neighborhoodSelectionType = self.neighborhoodSelectionType;
        vc.delegate = self.delegate;
    }
}


@end
