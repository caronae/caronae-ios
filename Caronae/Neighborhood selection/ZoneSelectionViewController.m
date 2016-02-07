#import "ZoneSelectionViewController.h"
#import "ZoneSelectionInputViewController.h"
#import "CaronaeZoneCell.h"

@interface ZoneSelectionViewController ()
@property (nonatomic) NSArray *zones;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic) NSMutableArray *selectedNeighborhoods;
@end

@implementation ZoneSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.type == ZoneSelectionZone) {
        self.title = @"Zonas";
        self.zones = [CaronaeDefaults defaults].zones;
    }
    else {
        self.title = self.selectedZone;
        self.zones = [CaronaeDefaults defaults].neighborhoods[self.selectedZone];
        self.selectedNeighborhoods = [[NSMutableArray alloc] init];
    }
}

- (void)finishSelection {
    [self.navigationController popToRootViewControllerAnimated:YES];
    if (self.neighborhoodSelectionType == NeighborhoodSelectionMany && [self.delegate respondsToSelector:@selector(hasSelectedNeighborhoods:inZone:)]) {
        [self.delegate hasSelectedNeighborhoods:self.selectedNeighborhoods inZone:self.selectedZone];
    }
    else if (self.neighborhoodSelectionType == NeighborhoodSelectionOne && [self.delegate respondsToSelector:@selector(hasSelectedNeighborhood:inZone:)]) {
        [self.delegate hasSelectedNeighborhood:self.selectedNeighborhoods.firstObject inZone:self.selectedZone];
    }
}

- (IBAction)didTapDoneButton:(id)sender {
    [self finishSelection];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.zones.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CaronaeZoneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Zone Cell" forIndexPath:indexPath];
    
    NSString *zone = self.zones[indexPath.row];
    UIColor *cellColor;
    
    if (self.type == ZoneSelectionZone) {
        cellColor = [CaronaeDefaults colorForZone:zone];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cellColor = [CaronaeDefaults colorForZone:self.selectedZone];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.zoneNameLabel.text = zone;
    cell.colorDetail.backgroundColor = cellColor;
    cell.zoneNameLabel.textColor = cellColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == ZoneSelectionZone) {
        if (![self.zones[indexPath.row] isEqualToString:@"Outra"]) {
            self.selectedZone = self.zones[indexPath.row];
            [self performSegueWithIdentifier:@"ViewNeighborhoods" sender:self];
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
            self.doneButton.enabled = (self.selectedNeighborhoods.count > 0);
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSString *selectedNeighborhood = self.zones[indexPath.row];
    [self.selectedNeighborhoods removeObject:selectedNeighborhood];
    
    self.doneButton.enabled = (self.selectedNeighborhoods.count > 0);
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
