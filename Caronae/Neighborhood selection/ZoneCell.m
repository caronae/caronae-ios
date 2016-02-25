#import "ZoneCell.h"

@implementation ZoneCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *detailBackgroundColor = _colorDetail.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        _colorDetail.backgroundColor = detailBackgroundColor;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *detailBackgroundColor = _colorDetail.backgroundColor;
    [super setSelected:selected animated:animated];
    
    if (selected) {
        _colorDetail.backgroundColor = detailBackgroundColor;
    }
}

@end
