#import "ZoneCell.h"
#import "ZoneSelectionViewController.h"
#import "ZoneSelectionInputViewController.h"
#import "NeighborhoodSelectionViewController.h"

@interface ZoneSelectionViewController () <NeighborhoodSelectionDelegate>
@property (nonatomic) NSArray *zones;
@end

@implementation ZoneSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Zonas";
    if (self.neighborhoodSelectionType == NeighborhoodSelectionMany) {
        self.zones = [@[CaronaeAllNeighborhoodsText] arrayByAddingObjectsFromArray:CaronaeConstants.defaults.zones];
    } else {
        self.zones = CaronaeConstants.defaults.zones;
    }
}

- (void)hasSelectedNeighborhoods:(NSArray *)neighborhoods {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.delegate hasSelectedNeighborhoods:neighborhoods inZone:self.selectedZone];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.zones.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZoneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Zone Cell"];
    
    NSString *zone = self.zones[indexPath.row];
    UIColor *cellColor = [CaronaeConstants colorForZone:zone];
    
    [cell setupCellWithZone:zone color:cellColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedZone = self.zones[indexPath.row];
    if ([selectedZone isEqualToString:@"Outra"]) {
        self.selectedZone = @"Outros";
        if (self.neighborhoodSelectionType == NeighborhoodSelectionOne) {
            [self performSegueWithIdentifier:@"OtherNeighborhood" sender:self];
        } else {
            [self hasSelectedNeighborhoods:@[]];
        }
        
        return;
    }
    
    if ([selectedZone isEqualToString:CaronaeAllNeighborhoodsText]) {
        self.selectedZone = @"";
        [self hasSelectedNeighborhoods:@[CaronaeAllNeighborhoodsText]];
        return;
    }
    
    self.selectedZone = selectedZone;
    [self performSegueWithIdentifier:@"ViewNeighborhoods" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewNeighborhoods"]) {
        NeighborhoodSelectionViewController *vc = segue.destinationViewController;
        vc.neighborhoodSelectionType = self.neighborhoodSelectionType;
        vc.selectedZone = self.selectedZone;
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"OtherNeighborhood"]) {
        ZoneSelectionInputViewController *vc = segue.destinationViewController;
        vc.neighborhoodSelectionType = self.neighborhoodSelectionType;
        vc.delegate = self.delegate;
    }
}


@end
