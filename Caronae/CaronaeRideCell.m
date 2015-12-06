#import "CaronaeRideCell.h"
#import "Ride.h"

@implementation CaronaeRideCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithRide:(Ride *)ride {
    _ride = ride;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm | dd/MM";
    
    if (ride.going) {
        _titleLabel.text = [[NSString stringWithFormat:@"%@ → %@", ride.neighborhood, ride.hub] uppercaseString];
    }
    else {
        _titleLabel.text = [[NSString stringWithFormat:@"%@ → %@", ride.hub, ride.neighborhood] uppercaseString];
    }
    _arrivalDateTimeLabel.text = [NSString stringWithFormat:@"Chegando às %@", [dateFormatter stringFromDate:ride.date]];
    _slotsLabel.text = [NSString stringWithFormat:@"%d %@", ride.slots, ride.slots == 1 ? @"vaga" : @"vagas"];
}

@end
