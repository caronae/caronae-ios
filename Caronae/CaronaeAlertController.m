#import "CaronaeAlertController.h"

static UIImageView *_separatorView;

@implementation CaronaeAlertController

+ (UIImageView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SeparatorColor"]];
    }
    return _separatorView;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SDCAlertControllerStyle)preferredStyle {
    CaronaeAlertController *alert = [super alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    [alert.contentView addSubview:[self separatorView]];
    
    return alert;
}

+ (instancetype)presentOkAlertWithTitle:(NSString *)title message:(NSString *)message {
    CaronaeAlertController *alert = [CaronaeAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:SDCAlertControllerStyleAlert];
    [alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleDefault handler:nil]];
    [alert presentWithCompletion:nil];
    return alert;
}

@end
