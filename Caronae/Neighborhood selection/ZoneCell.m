#import "ZoneCell.h"

@interface ZoneCell ()
@property (weak, nonatomic) IBOutlet UILabel *zoneNameLabel;
@property (weak, nonatomic) IBOutlet UIView *colorDetail;

@property (nonatomic, strong) UIColor *zoneColor;
@property (nonatomic) ZoneSelectionType type;
@end

@implementation ZoneCell

- (void)setupCellWithTitle:(NSString *)title color:(UIColor *)color type:(ZoneSelectionType)type {
    self.zoneNameLabel.text = title;
    self.zoneColor = color;
    self.type = type;
    
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
    
    if (self.type == ZoneSelectionZone) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = self.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }

}

@end
