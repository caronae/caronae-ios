#import "UIWindow+replaceRootViewController.h"

@implementation UIWindow (replaceRootViewController)

- (void)replaceViewControllerWith:(UIViewController*)viewController {
    if (!self.rootViewController) {
        self.rootViewController = viewController;
        return;
    }
    
    UIView *snapshot = [self snapshotViewAfterScreenUpdates:YES];
    [viewController.view addSubview:snapshot];
    self.rootViewController = viewController;
    [UIView animateWithDuration:0.3 animations:^{
        snapshot.layer.opacity = 0;
        snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
    } completion:^(BOOL finished) {
        [snapshot removeFromSuperview];
    }];
}

@end
