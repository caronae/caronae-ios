#import <SDCAlertView/SDCAlertController.h>

@interface CaronaeAlertController : SDCAlertController

+ (instancetype)presentOkAlertWithTitle:(NSString *)title message:(NSString *)message;

+ (instancetype)presentOkAlertWithTitle:(NSString *)title message:(NSString *)message handler:(void(^)())handler;

@end
