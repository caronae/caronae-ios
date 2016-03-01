#import <SDWebImage/UIImageView+WebCache.h>
#import "Ride.h"
#import "RideCell.h"

@implementation RideCell

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
    
    _badgeLabel.hidden = YES;
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
    _badgeLabel.hidden = YES;
}

- (void)updatePhoto {
    if (_ride.driver.profilePictureURL.length > 0) {
        [_photo sd_setImageWithURL:[NSURL URLWithString:_ride.driver.profilePictureURL]
                  placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                           options:SDWebImageRefreshCached | SDWebImageRetryFailed];
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

- (void)setBadgeCount:(int)badgeCount {
    _badgeCount = badgeCount;
    if (badgeCount > 0) {
        _badgeLabel.text = [NSString stringWithFormat:@"%d", badgeCount];
        _badgeLabel.hidden = NO;
    }
    else {
        _badgeLabel.hidden = YES;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *badgeBackgroundColor = _badgeLabel.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        _badgeLabel.backgroundColor = badgeBackgroundColor;
    }
}

@end
