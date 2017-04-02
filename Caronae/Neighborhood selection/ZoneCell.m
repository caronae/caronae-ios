#import "ZoneCell.h"

@interface ZoneCell ()

@property (weak, nonatomic) IBOutlet UILabel *zoneNameLabel;
@property (weak, nonatomic) IBOutlet UIView *colorDetail;
@property (nonatomic) UIColor *zoneColor;
@property (nonatomic) BOOL isNeighborhoodCell;

@end

@implementation ZoneCell

- (void)setupCellWithZone:(NSString *)zone color:(UIColor *)color {
    self.isNeighborhoodCell = NO;
    [self setupCellWithTitle:zone color:color];
}

- (void)setupCellWithNeighborhood:(NSString *)neighborhood color:(UIColor *)color {
    self.isNeighborhoodCell = YES;
    [self setupCellWithTitle:neighborhood color:color];
}

- (void)setupCellWithTitle:(NSString *)title color:(UIColor *)color {
    self.zoneNameLabel.text = title;
    self.zoneColor = color;
    
    [self updateStyle];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self updateStyle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self updateStyle];
}

- (void)updateStyle {
    self.colorDetail.backgroundColor = self.zoneColor;
    self.zoneNameLabel.textColor = self.zoneColor;
    
    if (self.isNeighborhoodCell) {
        self.accessoryType = self.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

}

@end
