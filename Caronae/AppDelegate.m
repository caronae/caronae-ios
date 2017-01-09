@import AFNetworking;
@import CRToast;
@import FBSDKCoreKit;
@import Firebase;
@import SVProgressHUD;
#import "AppDelegate.h"
#import "ChatViewController.h"
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
    
    [CRToastManager setDefaultOptions:@{
                                        kCRToastBackgroundColorKey: [UIColor colorWithRed:0.114 green:0.655 blue:0.365 alpha:1.000],
                                        }];
#ifdef DEBUG
    [self updateStatusBarDebugInfo];
#endif
    
    // Load the authentication screen if the user is not signed in
    if (UserService.instance.user) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeTabViewController"];
        self.window.rootViewController = initialViewController;
        [self.window makeKeyAndVisible];
        [self registerForNotifications];
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
        
        [RideService.instance updateOfferedRidesWithSuccess:^(NSArray<Ride *> * _Nonnull rides) {
            NSLog(@"Offered rides updated");
        } error:^(NSError * _Nullable error) {
            NSLog(@"Couldn't update offered rides");
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)didUpdateUser:(NSNotification *)notification {
#ifdef DEBUG
    [self updateStatusBarDebugInfo];
#endif
    
    if (!UserService.instance.user) {
        // User has logged out. Go to the authentication screen
        UIViewController *authViewController = [TokenViewController tokenViewController];
        [UIApplication.sharedApplication.keyWindow replaceViewControllerWith:authViewController];
    }
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
    if ([msgType isEqualToString:@"joinRequest"]) {
        tabBarController.selectedViewController = tabBarController.myRidesNavigationController;
    }
    else if ([msgType isEqualToString:@"accepted"] ||
             [msgType isEqualToString:@"refused"] ||
             [msgType isEqualToString:@"cancelled"] ||
             [msgType isEqualToString:@"quitter"]) {
        tabBarController.selectedViewController = tabBarController.activeRidesNavigationController;
    }
    else if ([msgType isEqualToString:@"finished"]) {
        tabBarController.selectedViewController = tabBarController.menuNavigationController;
        MenuViewController *menuViewController = tabBarController.menuViewController;
        [menuViewController openRidesHistory];
    }
    else if ([msgType isEqualToString:@"chat"]) {
        NSInteger rideID = [userInfo[@"rideId"] integerValue];
        tabBarController.selectedViewController = tabBarController.activeRidesNavigationController;
        ActiveRidesViewController *activeRidesViewController = tabBarController.activeRidesViewController;
        [activeRidesViewController openChatForRideWithID:rideID];
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


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Caronae" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Caronae.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                               NSInferMappingModelAutomaticallyOption : @(YES) };

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:CaronaeErrorDomain code:CaronaeErrorOpeningCoreDataStore userInfo:dict];

        NSLog(@"Unresolved Core Data error %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (void)deleteAllObjects:(NSString *)entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
        [self.managedObjectContext deleteObject:managedObject];
    }
    
    [self saveContext];
}


#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}


#pragma mark - Etc.

#ifdef DEBUG
- (void)updateStatusBarDebugInfo {
    // Show the current API server on the status bar
    NSString *debugMessage = [NSString stringWithFormat:@"API: %@", CaronaeAPIBaseURL];
    if (UserService.instance.user) {
        debugMessage = [NSString stringWithFormat:@"%@ User: %ld", debugMessage, (long)UserService.instance.user.id];
    }
    [CRToastManager dismissAllNotifications:false];
    [CRToastManager showNotificationWithOptions:@{
                                                  kCRToastTextKey: debugMessage,
                                                  kCRToastBackgroundColorKey: [UIColor colorWithWhite:0.96 alpha:1],
                                                  kCRToastTextColorKey: [UIColor blackColor],
                                                  kCRToastAnimationInTimeIntervalKey: @0,
                                                  kCRToastTimeIntervalKey: @DBL_MAX
                                                  }
                                completionBlock:nil];
}
#endif

@end
