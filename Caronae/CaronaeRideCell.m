#import <SDWebImage/UIImageView+WebCache.h>
#import "CaronaeRideCell.h"
#import "Ride.h"

@implementation CaronaeRideCell

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
    
    if (_ride.driver[@"profile_pic_url"] && ![_ride.driver[@"profile_pic_url"] isEqualToString:@""]) {
        [_photo sd_setImageWithURL:[NSURL URLWithString:_ride.driver[@"profile_pic_url"]]
                             placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                                      options:SDWebImageRefreshCached];
    }
    
    self.color = [CaronaeDefaults colorForZone:_ride.zone];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    _titleLabel.textColor = color;
    _arrivalDateTimeLabel.textColor = color;
    _slotsLabel.textColor = color;
    _photo.layer.borderColor = color.CGColor;
}

@end
