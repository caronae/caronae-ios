#import "TabBarController.h"
#import "UIApplication+topViewController.h"
#import "UIWindow+replaceRootViewController.h"
#import "Caronae-Swift.h"

@implementation TabBarController

- (instancetype)init {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeTabViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateUser:) name:CaronaeDidUpdateUserNotification object:nil];
    
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController isKindOfClass:UINavigationController.class]) {
            UINavigationController *navigationController = (UINavigationController *)viewController;
            UIViewController *viewController = navigationController.topViewController;
            
            if ([viewController isKindOfClass:AllRidesViewController.class]) {
                self.allRidesNavigationController = navigationController;
                self.allRidesViewController = (AllRidesViewController *)viewController;
            }
            else if ([viewController isKindOfClass:ActiveRidesViewController.class]) {
                self.activeRidesNavigationController = navigationController;
                self.activeRidesViewController = (ActiveRidesViewController *)viewController;
            }
            else if ([viewController isKindOfClass:MyRidesViewController.class]) {
                self.myRidesNavigationController = navigationController;
                self.myRidesViewController = (MyRidesViewController *)viewController;
            }
            else if ([viewController isKindOfClass:MenuViewController.class]) {
                self.menuNavigationController = navigationController;
                self.menuViewController = (MenuViewController *)viewController;
            }
        }
    }
}

- (void)didUpdateUser:(NSNotification *)notification {
    if (!UserService.instance.user) {
        // User has logged out. Go to the authentication screen
        UIViewController *authViewController = [TokenViewController tokenViewController];
        [UIApplication.sharedApplication.keyWindow replaceViewControllerWith:authViewController];
    }
}

@end
