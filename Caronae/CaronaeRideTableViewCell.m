#import "CaronaeRideTableViewCell.h"
#import "Ride.h"

@implementation CaronaeRideTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithRide:(Ride *)ride canJoin:(BOOL)joinEnabled {
    _ride = ride;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm | dd/MM";

    _titleLabel.text = [NSString stringWithFormat:@"%@ → %@", ride.neighborhood, ride.hub];
    _arrivalDateTimeLabel.text = [NSString stringWithFormat:@"Chegando às %@", [dateFormatter stringFromDate:ride.date]];
    _slotsLabel.text = [NSString stringWithFormat:@"%d %@", ride.slots, ride.slots == 1 ? @"vaga" : @"vagas"];
    _driverLabel.text = [NSString stringWithFormat:@"%@ | %@", ride.driverName, ride.driverCourse];
    _friendsInCommonLabel.text = [NSString stringWithFormat:@"Amigos em comum: %d", 0];
    _driverMessageLabel.text = ride.notes;
    _routeLabel.text = ride.route;
    
    _requestRideButton.enabled = joinEnabled;
}

- (IBAction)didTapJoinRideButton:(id)sender {
    [self.delegate tappedJoinRide:self];
}

@end
