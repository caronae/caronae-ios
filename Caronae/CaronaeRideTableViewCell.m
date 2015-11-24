#import "CaronaeRideTableViewCell.h"

@implementation CaronaeRideTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithRide:(NSDictionary *)ride {
    _ride = ride;
    
    NSDateFormatter *dateParserFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateParserFormatter.dateFormat = @"yyyy-MM-dd hh:mm";
    dateFormatter.dateFormat = @"hh:mm | dd/MM";
    NSDate *arrivalDate = [dateParserFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", ride[@"date"], ride[@"time"]]];
    
    _titleLabel.text = [NSString stringWithFormat:@"%@ → %@", ride[@"neighborhood"], ride[@"hub"]];
    _arrivalDateTimeLabel.text = [NSString stringWithFormat:@"Chegando às %@", [dateFormatter stringFromDate:arrivalDate]];
    _slotsLabel.text = [NSString stringWithFormat:@"%d %@", (int)ride[@"slots"], [ride[@"slots"] isEqual: @(1)] ? @"vaga" : @"vagas"];
    _driverLabel.text = [NSString stringWithFormat:@"%@ | %@", ride[@"driverName"], ride[@"course"]];
    _friendsInCommonLabel.text = [NSString stringWithFormat:@"Amigos em comum: %d", 0];
    _driverMessageLabel.text = ride[@"description"];
    _routeLabel.text = ride[@"route"];
}

@end
