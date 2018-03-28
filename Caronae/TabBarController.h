@import UIKit;

@class MyRidesViewController, AllRidesViewController, MenuViewController;

@interface TabBarController : UITabBarController

@property (nonatomic, strong) AllRidesViewController *allRidesViewController;
@property (nonatomic, strong) UINavigationController *allRidesNavigationController;

@property (nonatomic, strong) MyRidesViewController *myRidesViewController;
@property (nonatomic, strong) UINavigationController *myRidesNavigationController;

@property (nonatomic, strong) MenuViewController *menuViewController;
@property (nonatomic, strong) UINavigationController *menuNavigationController;

@end
