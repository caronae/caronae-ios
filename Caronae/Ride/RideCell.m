#import "UIImageView+crn_setImageWithURL.h"
#import "Ride.h"
#import "RideCell.h"

@implementation RideCell

static NSDateFormatter *dateFormatter;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm | E | dd/MM";
    }
    return self;
}

- (void)configureCellWithRide:(Ride *)ride {
    [self configureBasicCellWithRide:ride];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (ride.going) {
        _arrivalDateTimeLabel.text = [NSString stringWithFormat:@"Chegando às %@", self.dateString];
    }
    else {
        _arrivalDateTimeLabel.text = [NSString stringWithFormat:@"Saindo às %@", self.dateString];
    }
}

- (void)configureHistoryCellWithRide:(Ride *)ride {
    [self configureBasicCellWithRide:ride];
    _arrivalDateTimeLabel.text = [NSString stringWithFormat:@"Chegou às %@", self.dateString];
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureBasicCellWithRide:(Ride *)ride {
    _ride = ride;
    _titleLabel.text = [_ride.title uppercaseString];
    
    // Display first and last names only
    NSArray<NSString *> *names = [_ride.driver.name componentsSeparatedByString:@" "];
    NSString *displayName = names.count > 1 ? [NSString stringWithFormat:@"%@ %@", names.firstObject, names.lastObject] : _ride.driver.name;
    _driverNameLabel.text = displayName;
    
    [self updatePhoto];
    self.color = [CaronaeDefaults colorForZone:_ride.zone];
    
    _badgeLabel.hidden = YES;
}

- (NSString *)dateString {
    return [dateFormatter stringFromDate:_ride.date].capitalizedString;
}

- (void)updatePhoto {
    if (_ride.driver.profilePictureURL.length > 0) {
        [_photo crn_setImageWithURL:[NSURL URLWithString:_ride.driver.profilePictureURL]];
    }
    else {
        _photo.image = [UIImage imageNamed:@"Profile Picture"];
    }
}

- (void)setColor:(UIColor *)color {
    _color = color;
    _titleLabel.textColor = color;
    _arrivalDateTimeLabel.textColor = color;
    _driverNameLabel.textColor = color;
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
