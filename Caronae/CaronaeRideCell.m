#import <SDWebImage/UIImageView+WebCache.h>
#import "CaronaeRideCell.h"
#import "Ride.h"

@implementation CaronaeRideCell

- (void)configureCellWithRide:(Ride *)ride {
    _ride = ride;
    
    _titleLabel.text = [_ride.title uppercaseString];
    
    [self updatePhoto];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm | dd/MM";
    if (ride.going) {
        _arrivalDateTimeLabel.text = [NSString stringWithFormat:@"Chegando às %@", [dateFormatter stringFromDate:_ride.date]];
    }
    else {
        _arrivalDateTimeLabel.text = [NSString stringWithFormat:@"Saindo às %@", [dateFormatter stringFromDate:_ride.date]];
    }
    
    _slotsLabel.text = [NSString stringWithFormat:@"%d %@", ride.slots, ride.slots == 1 ? @"vaga" : @"vagas"];
    
    self.color = [CaronaeDefaults colorForZone:_ride.zone];
}


- (void)configureHistoryCellWithRide:(Ride *)ride {
    _ride = ride;
    
    _titleLabel.text = [_ride.title uppercaseString];
    [self updatePhoto];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm | dd/MM";
    _arrivalDateTimeLabel.text = [NSString stringWithFormat:@"Chegou às %@", [dateFormatter stringFromDate:_ride.date]];
    
    _slotsLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)ride.users.count, ride.users.count == 1 ? @"caronista" : @"caronistas"];
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.color = [CaronaeDefaults colorForZone:_ride.zone];
}

- (void)updatePhoto {
    if (_ride.driver[@"profile_pic_url"] && [_ride.driver[@"profile_pic_url"] isKindOfClass:[NSString class]] && ![_ride.driver[@"profile_pic_url"] isEqualToString:@""]) {
        [_photo sd_setImageWithURL:[NSURL URLWithString:_ride.driver[@"profile_pic_url"]]
                  placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                           options:SDWebImageRefreshCached];
    }
    else {
        _photo.image = [UIImage imageNamed:@"Profile Picture"];
    }
}

- (void)setColor:(UIColor *)color {
    _color = color;
    _titleLabel.textColor = color;
    _arrivalDateTimeLabel.textColor = color;
    _slotsLabel.textColor = color;
    _photo.layer.borderColor = color.CGColor;
    self.tintColor = color;
}

@end
