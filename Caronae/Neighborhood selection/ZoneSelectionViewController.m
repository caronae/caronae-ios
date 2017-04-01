#import "ZoneCell.h"
#import "ZoneSelectionViewController.h"
#import "ZoneSelectionInputViewController.h"

@interface ZoneSelectionViewController ()
@property (nonatomic) NSArray *zones;
@property (nonatomic) UIBarButtonItem *doneButton;
@property (nonatomic) NSMutableArray *selectedNeighborhoods;
@end

@implementation ZoneSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.type == ZoneSelectionZone) {
        self.title = @"Zonas";
        if (self.neighborhoodSelectionType == NeighborhoodSelectionMany) {
            self.zones = [@[CaronaeAllNeighborhoodsText] arrayByAddingObjectsFromArray:[CaronaeConstants defaults].zones];
        }
        else {
            self.zones = [CaronaeConstants defaults].zones;
        }
    }
    else {
        self.title = self.selectedZone;
        self.zones = [CaronaeConstants defaults].neighborhoods[self.selectedZone];
        self.selectedNeighborhoods = [[NSMutableArray alloc] init];
        if (self.neighborhoodSelectionType == NeighborhoodSelectionMany) {
            self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Sel. todos" style:UIBarButtonItemStyleDone target:self action:@selector(finishSelection)];
            self.navigationItem.rightBarButtonItem = self.doneButton;
        }
    }
}

- (void)finishSelection {
    [self.navigationController popToRootViewControllerAnimated:YES];
    if (self.neighborhoodSelectionType == NeighborhoodSelectionMany && [self.delegate respondsToSelector:@selector(hasSelectedNeighborhoods:inZone:)]) {
        NSArray *selectedNeighborhoods;
        if (self.selectedNeighborhoods.count == 0) {
            selectedNeighborhoods = @[self.selectedZone];
        }
        else {
            if (self.selectedNeighborhoods.count == self.zones.count) {
                selectedNeighborhoods = @[self.selectedZone];
            }
            else {
                selectedNeighborhoods = self.selectedNeighborhoods;
            }
        }

        [self.delegate hasSelectedNeighborhoods:selectedNeighborhoods inZone:self.selectedZone];
    }
    else if (self.neighborhoodSelectionType == NeighborhoodSelectionOne && [self.delegate respondsToSelector:@selector(hasSelectedNeighborhood:inZone:)]) {
        [self.delegate hasSelectedNeighborhood:self.selectedNeighborhoods.firstObject inZone:self.selectedZone];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.zones.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZoneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Zone Cell" forIndexPath:indexPath];
    
    NSString *zone = self.zones[indexPath.row];
    UIColor *cellColor;
    
    if (self.type == ZoneSelectionZone) {
        cellColor = [CaronaeConstants colorForZone:zone];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cellColor = [CaronaeConstants colorForZone:self.selectedZone];
        if (self.neighborhoodSelectionType == NeighborhoodSelectionMany && cell.selected) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    cell.zoneNameLabel.text = zone;
    cell.colorDetail.backgroundColor = cellColor;
    cell.zoneNameLabel.textColor = cellColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == ZoneSelectionZone) {
        if (![self.zones[indexPath.row] isEqualToString:@"Outra"]) {
            if (![self.zones[indexPath.row] isEqualToString:CaronaeAllNeighborhoodsText]) {
                self.selectedZone = self.zones[indexPath.row];
                [self performSegueWithIdentifier:@"ViewNeighborhoods" sender:self];
            }
            else {
                self.selectedZone = @"";
                self.selectedNeighborhoods = [NSMutableArray arrayWithObject:CaronaeAllNeighborhoodsText];
                [self finishSelection];
            }
            
        }
        else {
            self.selectedZone = @"Outros";
            if (self.neighborhoodSelectionType == NeighborhoodSelectionOne) {
                [self performSegueWithIdentifier:@"OtherNeighborhood" sender:self];
            }
            else if (self.neighborhoodSelectionType == NeighborhoodSelectionMany) {
                self.selectedNeighborhoods = [NSMutableArray arrayWithObject:@"Outros"];
                [self finishSelection];
            }
        }
    }
    else {
        NSString *selectedNeighborhood = self.zones[indexPath.row];
        [self.selectedNeighborhoods addObject:selectedNeighborhood];
        
        if (self.neighborhoodSelectionType == NeighborhoodSelectionOne) {
            [self finishSelection];
        }
        else if (self.neighborhoodSelectionType == NeighborhoodSelectionMany) {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.doneButton.title = (self.selectedNeighborhoods.count > 0) ? @"OK" : @"Sel. todos";
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSString *selectedNeighborhood = self.zones[indexPath.row];
    [self.selectedNeighborhoods removeObject:selectedNeighborhood];
    
    self.doneButton.title = (self.selectedNeighborhoods.count > 0) ? @"OK" : @"Sel. todos";
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
