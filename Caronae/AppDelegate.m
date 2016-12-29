@import Firebase;

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <CRToast/CRToast.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "AppDelegate.h"
#import "ChatViewController.h"
#import "Message+CoreDataProperties.h"
#import "Notification+CoreDataProperties.h"
#import "NotificationStore.h"
#import "TabBarController.h"
#import "Caronae-Swift.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.75f]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [CRToastManager setDefaultOptions:@{
                                        kCRToastBackgroundColorKey: [UIColor colorWithRed:0.114 green:0.655 blue:0.365 alpha:1.000],
                                        }];
    
    [self configureFirebase];
    
    // Load home screen if the user has already signed in
    if ([UserController sharedInstance].user) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeTabViewController"];
        self.window.rootViewController = initialViewController;
        [self.window makeKeyAndVisible];
        [self registerForNotifications];
    }
    
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

- (void)updateApplicationBadgeNumber {
    NSUInteger totalUnreadNotifications = [NotificationStore getNotificationsOfType:NotificationTypeAll].count;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalUnreadNotifications];
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
    [self connectToFcm];
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


#pragma mark - Etc

- (UIViewController *)topViewController {
    return [self topViewControllerWithRootViewController:UIApplication.sharedApplication.keyWindow.rootViewController];
}

- (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}


#pragma mark - Notification handling

- (BOOL)handleNotification:(NSDictionary *)userInfo {
    if (!userInfo[@"msgType"]) return NO;
    NSString *msgType = userInfo[@"msgType"];
    
    // Handle chat messages
    if ([msgType isEqualToString:@"chat"]) {
        [self handleChatNotification:userInfo];
    }
    // Handle 'join request' notifications
    else if ([msgType isEqualToString:@"joinRequest"]) {
        [self handleJoinRequestNotification:userInfo];
    }
    // Handle 'join request accepted' notifications
    else if ([msgType isEqualToString:@"accepted"]) {
        NSNumber *rideID = @([userInfo[@"rideId"] intValue]);
        
        // Create fake ride
        Ride *ride = [[Ride alloc] init];
        ride.rideID = [rideID longValue];
        
        // Create chat for ride and subscribe to it
        Chat *chat = [[ChatService sharedInstance] chatForRide:ride];
        [[ChatService sharedInstance] subscribeToChat:chat];
        
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
            [CRToastManager showNotificationWithOptions:@{kCRToastTextKey: userInfo[@"message"]} completionBlock:nil];
        }
    }
    // Handle 'ride cancelled' and 'ride finished' notifications
    else if ([msgType isEqualToString:@"cancelled"] || [msgType isEqualToString:@"finished"]) {
        [self handleFinishedNotification:userInfo];
    }
    else if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive && userInfo[@"message"] && ![userInfo[@"message"] isEqualToString:@""]) {
        [CRToastManager showNotificationWithOptions:@{kCRToastTextKey: userInfo[@"message"]} completionBlock:nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeNotificationReceivedNotification object:self userInfo:userInfo];
    
    return YES;
}

- (void)handleChatNotification:(NSDictionary *)userInfo {
    int senderId = [userInfo[@"senderId"] intValue];
    int currentUserId = [[UserController sharedInstance].user.userID intValue];
    
    // We don't need to handle a message if it's from the logged user
    if (senderId == currentUserId) {
        return;
    }
    
    NSNumber *rideID = @([userInfo[@"rideId"] intValue]);
    NSLog(@"Received chat message for ride %@", rideID);
    
    NSManagedObjectContext *context = [self managedObjectContext];
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(Message.class) inManagedObjectContext:context];
    message.text = userInfo[@"message"];
    message.incoming = @(YES);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    message.sentDate = [dateFormatter dateFromString:userInfo[@"time"]];
    message.rideID = rideID;
    message.senderName = userInfo[@"senderName"];
    message.senderId = @([userInfo[@"senderId"] intValue]);
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", error.localizedDescription);
        return;
    }
    
    NSString *notificationBody = [NSString stringWithFormat:@"%@: %@", message.senderName, message.text];
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = message.sentDate;
        notification.alertBody = notificationBody;
        notification.userInfo = userInfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        
        Notification *caronaeNotification = [Notification notificationWithRideID:rideID date:message.sentDate type:@"chat" context:self.managedObjectContext];
        [NotificationStore insertNotification:caronaeNotification];
    }
    else {
        ChatViewController *topVC = (ChatViewController *)[self topViewController];
        // Present notification only if the chat window is not already open
        if (![topVC isKindOfClass:ChatViewController.class] || ![message.rideID isEqualToNumber:@(topVC.chat.ride.rideID)]) {
            Notification *caronaeNotification = [Notification notificationWithRideID:rideID date:message.sentDate type:@"chat" context:self.managedObjectContext];
            [NotificationStore insertNotification:caronaeNotification];
            
            [CRToastManager showNotificationWithOptions:@{kCRToastTextKey: notificationBody} completionBlock:nil];
        }
    }
    
}

- (void)handleJoinRequestNotification:(NSDictionary *)userInfo {
    NSNumber *rideID = @([userInfo[@"rideId"] intValue]);

    Notification *caronaeNotification = [Notification notificationWithRideID:rideID date:[NSDate date] type:@"joinRequest" context:self.managedObjectContext];
    [NotificationStore insertNotification:caronaeNotification];
    
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
        [CRToastManager showNotificationWithOptions:@{kCRToastTextKey: userInfo[@"message"]} completionBlock:nil];
    }
}

- (void)handleFinishedNotification:(NSDictionary *)userInfo {
    NSNumber *rideID = @([userInfo[@"rideId"] intValue]);
    
    [NotificationStore clearNotificationsForRide:rideID ofType:NotificationTypeAll];
    
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
        [CRToastManager showNotificationWithOptions:@{kCRToastTextKey: userInfo[@"message"]} completionBlock:nil];
    }
}

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
        NSNumber *rideID = @([userInfo[@"rideId"] intValue]);
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

@end
