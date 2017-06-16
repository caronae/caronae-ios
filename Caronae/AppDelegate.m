@import AFNetworking;
@import CRToast;
@import FBSDKCoreKit;
@import Firebase;
@import SVProgressHUD;
#import "AppDelegate.h"
#import "TabBarController.h"
#import "UIWindow+replaceRootViewController.h"
#import "Caronae-Swift.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.75f]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [self configureRealm];
    [self configureFirebase];
    [self configureFacebookWithLaunchOptions:launchOptions];
    
    // Prepare beepSound for notifications while app is in foreground
    NSURL *soundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"beep" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_beepSound);
    
    [CRToastManager setDefaultOptions:@{
                                        kCRToastBackgroundColorKey: [UIColor colorWithRed:0.114 green:0.655 blue:0.365 alpha:1.000],
                                        }];
    
    // Load the authentication screen if the user is not signed in
    if (UserService.instance.user) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeTabViewController"];
        self.window.rootViewController = initialViewController;
        [self.window makeKeyAndVisible];
        [self registerForNotifications];
        [self checkIfUserNeedsToFinishProfile];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateUser:) name:CaronaeDidUpdateUserNotification object:nil];
    
    // Update application badge number and listen to notification updates
    [self updateApplicationBadgeNumber];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateApplicationBadgeNumber) name:CaronaeDidUpdateNotifications object:nil];
    
    // Check if the app was opened by a remote notification
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) {
        [self application:application didReceiveRemoteNotification:remoteNotification];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self disconnectFromFcm];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (UserService.instance.user) {
        [self connectToFcm];
        
        [RideService.instance updateMyRidesWithSuccess:^{
            NSLog(@"My rides updated");
        } error:^(NSError * _Nonnull error) {
            NSLog(@"Couldn't update my rides");
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)didUpdateUser:(NSNotification *)notification {
    if (!UserService.instance.user) {
        // Check if the logout was forced by the server
        id signOutRequired = notification.userInfo[CaronaeSignOutRequiredKey];
        if (signOutRequired && [signOutRequired boolValue]) {
            [CaronaeAlertController presentOkAlertWithTitle:@"Erro de autorização" message:@"Ocorreu um erro autenticando seu usuário. Sua chave de acesso pode ter sido redefinida ou suspensa.\n\nPara sua segurança, você será levado à tela de login." handler:^{
                [self displayAuthenticationScreen];
            }];
        } else {
            [self displayAuthenticationScreen];
        }
        
        [self disconnectFromFcm];
    } else {
        [self registerForNotifications];
        [self connectToFcm];
        
        // Update my rides after login
        [RideService.instance updateMyRidesWithSuccess:^{
            NSLog(@"My rides updated");
        } error:^(NSError * _Nonnull error) {
            NSLog(@"Couldn't update my rides");
        }];
        
        [self checkIfUserNeedsToFinishProfile];
    }
}

- (void)checkIfUserNeedsToFinishProfile {
    if (UserService.instance.user.isProfileIncomplete) {
        // delay until the view is ready
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self displayFinishProfileScreen];
        });
    }
}

- (void)displayAuthenticationScreen {
    UIViewController *authViewController = [TokenViewController tokenViewController];
    [UIApplication.sharedApplication.keyWindow replaceViewControllerWith:authViewController];
}

- (void)displayFinishProfileScreen {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] init];
    UINavigationController *welcomeNavigationController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
    welcomeNavigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    welcomeNavigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [rootViewController presentViewController:welcomeNavigationController animated:YES completion:nil];
}

#pragma mark - Facebook SDK

- (void)configureFacebookWithLaunchOptions:(NSDictionary *)launchOptions {
    [[FBSDKApplicationDelegate sharedInstance] application:UIApplication.sharedApplication
                             didFinishLaunchingWithOptions:launchOptions];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FBTokenChanged:) name:FBSDKAccessTokenDidChangeNotification object:nil];
}


- (void)FBTokenChanged:(NSNotification *)notification {
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    NSLog(@"Facebook Access Token did change. New access token is %@", token.tokenString);
    
    id fbToken;
    if (token.tokenString) {
        fbToken = token.tokenString;
    } else {
        fbToken = [NSNull null];
    }
    
    id fbID;
    if (notification.userInfo[FBSDKAccessTokenDidChangeUserID]) {
        if (token.userID) {
            NSLog(@"Facebook has loogged in with Facebook ID %@.", token.userID);
            fbID = token.userID;
        } else {
            NSLog(@"User has logged out from Facebook.");
            fbID = [NSNull null];
        }
    }
    
    [UserService.instance updateFacebookID:fbID token:fbToken success:^{
        NSLog(@"Updated user's Facebook credentials on server.");
    } error:^(NSError * _Nonnull error) {
        NSLog(@"Error updating user's Facebook credentials on server: %@", error.localizedDescription);
    }];
}


#pragma mark - Notification handling

- (void)setActiveScreenAccordingToNotification:(NSDictionary *)userInfo {
    if (!userInfo[@"msgType"]) return;
    
    TabBarController *tabBarController = (TabBarController *)self.window.rootViewController;
    NSString *msgType = userInfo[@"msgType"];
    if ([msgType isEqualToString:@"joinRequest"] ||
        [msgType isEqualToString:@"accepted"] ||
        [msgType isEqualToString:@"refused"] ||
        [msgType isEqualToString:@"cancelled"] ||
        [msgType isEqualToString:@"quitter"]) {
        tabBarController.selectedViewController = tabBarController.myRidesNavigationController;
    }
    else if ([msgType isEqualToString:@"finished"]) {
        tabBarController.selectedViewController = tabBarController.menuNavigationController;
        MenuViewController *menuViewController = tabBarController.menuViewController;
        [menuViewController openRidesHistory];
    }
    else if ([msgType isEqualToString:@"chat"]) {
        NSInteger rideID = [userInfo[@"rideId"] integerValue];
        // Check if chat for rideID is already opened
        UIViewController *topViewController = [UIApplication sharedApplication].topViewController;
        if ([topViewController isKindOfClass:[ChatViewController class]]) {
            if ([((ChatViewController *)topViewController) ride].id == rideID) {
                return;
            }
        }
        // Open chat for rideID
        tabBarController.selectedViewController = tabBarController.myRidesNavigationController;
        MyRidesViewController *myRidesViewController = tabBarController.myRidesViewController;
        [myRidesViewController openChatForRideWithID:rideID];
    }
}


#pragma mark - Firebase Messaging (FCM)

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [self didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    [self didReceiveRemoteNotification:userInfo completionHandler:handler];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self didReceiveLocalNotification:notification];
}

@end
