#import <UIKit/UIKit.h>
#import "ActiveRidesViewController.h"
#import "AllRidesViewController.h"
#import "MenuViewController.h"
#import "MyRidesViewController.h"

@interface TabBarController : UITabBarController

@property (nonatomic, strong) AllRidesViewController *allRidesViewController;
@property (nonatomic, strong) UINavigationController *allRidesNavigationController;

@property (nonatomic, strong) ActiveRidesViewController *activeRidesViewController;
@property (nonatomic, strong) UINavigationController *activeRidesNavigationController;

@property (nonatomic, strong) MyRidesViewController *myRidesViewController;
@property (nonatomic, strong) UINavigationController *myRidesNavigationController;

@property (nonatomic, strong) MenuViewController *menuViewController;
@property (nonatomic, strong) UINavigationController *menuNavigationController;

@end
