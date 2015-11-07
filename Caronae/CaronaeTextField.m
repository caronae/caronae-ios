#import "CaronaeTextField.h"

@implementation CaronaeTextField

- (void)layoutSubviews {
    CALayer *bottomLine = [CALayer layer];
    bottomLine.frame = CGRectMake(0.0f, self.frame.size.height - 1.0f, self.frame.size.width, 1.0f);
    bottomLine.backgroundColor = [UIColor colorWithRed:0.576 green:0.580 blue:0.576 alpha:1.000].CGColor;
    self.borderStyle = UITextBorderStyleNone;
    [self.layer addSublayer:bottomLine];
    
    [super layoutSubviews];
}

@end
