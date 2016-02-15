#import "UIViewController+isVisible.h"

@implementation UIViewController (isVisible)

- (BOOL)isVisible {
    return self.isViewLoaded && self.view.window;
}

@end
