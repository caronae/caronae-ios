#import "CaronaePhoneTextField.h"

@interface CaronaePhoneTextField ()
@property (nonatomic) BOOL isActive;
@property (nonatomic, strong) CALayer *bottomLine;
@end


@implementation CaronaePhoneTextField

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.font = [UIFont systemFontOfSize:16.0f];
    }
    return self;
}

- (void)layoutSubviews {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 32.0);
    
    self.borderStyle = UITextBorderStyleNone;
    self.bottomLine.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    [super layoutSubviews];
}

- (BOOL)becomeFirstResponder {
    BOOL isFirstResponder = [super becomeFirstResponder];
    self.isActive = isFirstResponder;
    [self layoutSubviews];
    return isFirstResponder;
}

- (BOOL)resignFirstResponder {
    BOOL resignedFirstResponder = [super resignFirstResponder];
    self.isActive = !resignedFirstResponder;
    [self layoutSubviews];
    return resignedFirstResponder;
}

- (CALayer *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [CALayer layer];
        _bottomLine.frame = CGRectMake(0.0f, self.frame.size.height - 1.0f, self.frame.size.width, 1.0f);
        [self.layer addSublayer:_bottomLine];
    }
    return _bottomLine;
}

- (UIColor *)bottomLineColor {
//    CGFloat alpha = self.isActive ? 1 : 0.5;
    CGFloat alpha = 1;
    return [UIColor colorWithWhite:0.6 alpha:alpha];
}

@end
