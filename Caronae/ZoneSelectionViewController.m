#import "ZoneSelectionViewController.h"
#import "CaronaeZoneCell.h"

@interface ZoneSelectionViewController ()
@property (nonatomic) NSString *selectedZone;
@property (nonatomic) NSString *selectedNeighborhood;
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
    CaronaeZoneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Zone Cell" forIndexPath:indexPath];
    
    NSString *zone = self.zones[indexPath.row];
    NSDictionary *zoneColors = [CaronaeDefaults defaults].zoneColors;
    cell.zoneNameLabel.text = zone;
    
    if (self.type == ZoneSelectionZone) {
        cell.colorDetail.backgroundColor = zoneColors[zone];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.colorDetail.backgroundColor = zoneColors[self.selectedZone];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.type == ZoneSelectionZone) {
        self.selectedZone = self.zones[indexPath.row];
        [self performSegueWithIdentifier:@"ViewNeighborhoods" sender:self];
    }
    else {
        self.selectedNeighborhood = self.zones[indexPath.row];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self.delegate hasSelectedNeighborhood:self.selectedNeighborhood inZone:self.selectedZone];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewNeighborhoods"]) {
        ZoneSelectionViewController *vc = segue.destinationViewController;
        vc.type = ZoneSelectionNeighborhood;
        vc.selectedZone = self.selectedZone;
        vc.delegate = self.delegate;
    }
}


@end
