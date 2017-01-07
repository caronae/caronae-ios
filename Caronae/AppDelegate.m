@import AFNetworking;
@import CRToast;
@import FBSDKCoreKit;
@import Google;
@import SVProgressHUD;
#import "AppDelegate.h"
#import "Chat.h"
#import "ChatStore.h"
#import "ChatViewController.h"
#import "Notification+CoreDataProperties.h"
#import "NotificationStore.h"
#import "TabBarController.h"
#import "UIWindow+replaceRootViewController.h"
#import "Caronae-Swift.h"

@interface AppDelegate () <GGLInstanceIDDelegate, GCMReceiverDelegate>
@property (nonatomic, strong) void (^registrationHandler) (NSString *registrationToken, NSError *error);
@property (nonatomic, assign) BOOL connectedToGCM;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.75f]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [self configureRealm];
    [self configureGCM];
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

- (void)updateApplicationBadgeNumber {
    NSUInteger totalUnreadNotifications = [NotificationStore getNotificationsOfType:NotificationTypeAll].count;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalUnreadNotifications];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[GCMService sharedInstance] disconnect];
    NSLog(@"Disconnected from GCM");
    _connectedToGCM = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (UserService.instance.user && !_connectedToGCM) {
        [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
            if (error && error.code != kGCMServiceErrorCodeAlreadyConnected) {
                NSLog(@"Could not connect to GCM (application became active): %@", error.localizedDescription);
            } else if (!error) {
                _connectedToGCM = true;
                NSLog(@"Connected to GCM (application became active)");
                [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeGCMConnectedNotification object:nil userInfo:nil];
            }
        }];
    }
    if (UserService.instance.user) {
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

- (void)registerForNotifications {
    UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

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
        
        [Chat subscribeToTopicID:[Chat topicIDwithRideID:rideID]];
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [CRToastManager showNotificationWithOptions:@{kCRToastTextKey: userInfo[@"message"]} completionBlock:nil];
        }
    }
    // Handle 'ride cancelled' and 'ride finished' notifications
    else if ([msgType isEqualToString:@"cancelled"] || [msgType isEqualToString:@"finished"]) {
        [self handleFinishedNotification:userInfo];
    }
    else if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive && userInfo[@"message"] && ![userInfo[@"message"] isEqualToString:@""]) {
        [CRToastManager showNotificationWithOptions:@{kCRToastTextKey: userInfo[@"message"]} completionBlock:nil];
    }
    
    return YES;
}

- (void)handleChatNotification:(NSDictionary *)userInfo {
    long senderId = [userInfo[@"senderId"] longValue];
    long currentUserId = UserService.instance.user.id;
    
    // We don't need to handle a message if it's from the logged user
    if (senderId == currentUserId) {
        return;
    }
    
    // TODO: handle notification
//    NSNumber *rideID = @([userInfo[@"rideId"] longValue]);
//    NSLog(@"Received chat message for ride %@", rideID);
//    
//    NSManagedObjectContext *context = [self managedObjectContext];
//    Message *message = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(Message.class) inManagedObjectContext:context];
//    message.text = userInfo[@"message"];
//    message.incoming = @(YES);
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    message.sentDate = [dateFormatter dateFromString:userInfo[@"time"]];
//    message.rideID = rideID;
//    message.senderName = userInfo[@"senderName"];
//    message.senderId = @([userInfo[@"senderId"] intValue]);
//    
//    NSError *error;
//    if (![context save:&error]) {
//        NSLog(@"Whoops, couldn't save: %@", error.localizedDescription);
//        return;
//    }
//    
//    NSString *notificationBody = [NSString stringWithFormat:@"%@: %@", message.senderName, message.text];
//    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
//        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        notification.fireDate = message.sentDate;
//        notification.alertBody = notificationBody;
//        notification.userInfo = userInfo;
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//        
//        Notification *caronaeNotification = [Notification notificationWithRideID:rideID date:message.sentDate type:@"chat" context:self.managedObjectContext];
//        [NotificationStore insertNotification:caronaeNotification];
//    }
//    else {
//        ChatViewController *topVC = (ChatViewController *)[self topViewController];
//        // Present notification only if the chat window is not already open
//        if (![topVC isKindOfClass:ChatViewController.class] || ![message.rideID isEqualToNumber:@(topVC.chat.ride.rideID)]) {
//            Notification *caronaeNotification = [Notification notificationWithRideID:rideID date:message.sentDate type:@"chat" context:self.managedObjectContext];
//            [NotificationStore insertNotification:caronaeNotification];
//            
//            [CRToastManager showNotificationWithOptions:@{kCRToastTextKey: notificationBody} completionBlock:nil];
//        }
//    }
    
}

- (void)handleJoinRequestNotification:(NSDictionary *)userInfo {
    NSNumber *rideID = @([userInfo[@"rideId"] intValue]);

    Notification *caronaeNotification = [Notification notificationWithRideID:rideID date:[NSDate date] type:@"joinRequest" context:self.managedObjectContext];
    [NotificationStore insertNotification:caronaeNotification];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [CRToastManager showNotificationWithOptions:@{kCRToastTextKey: userInfo[@"message"]} completionBlock:nil];
    }
}

- (void)handleFinishedNotification:(NSDictionary *)userInfo {
    NSNumber *rideID = @([userInfo[@"rideId"] intValue]);
    
    [NotificationStore clearNotificationsForRide:rideID ofType:NotificationTypeAll];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
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

#pragma mark - Google Cloud Messaging (GCM)

- (void)configureGCM {
    // Configure the Google context: parses the GoogleService-Info.plist, and initializes
    // the services that have entries in the file
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    _gcmSenderID = [[[GGLContext sharedInstance] configuration] gcmSenderID];
    
    GCMConfig *gcmConfig = [GCMConfig defaultConfig];
    gcmConfig.receiverDelegate = self;
    gcmConfig.logLevel = kGCMLogLevelError;
    [[GCMService sharedInstance] startWithConfig:gcmConfig];
    
    __weak typeof(self) weakSelf = self;
    // Handler for registration token request
    _registrationHandler = ^(NSString *registrationToken, NSError *error){
        if (!error && registrationToken != nil) {
            NSLog(@"GCM Registration Token: %@", registrationToken);
            UserService.instance.userGCMToken = registrationToken;
            if (!weakSelf.connectedToGCM) {
                [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
                    if (error && error.code != kGCMServiceErrorCodeAlreadyConnected) {
                        NSLog(@"Could not connect to GCM (registration): %@", error.localizedDescription);
                    } else if (!error) {
                        weakSelf.connectedToGCM = true;
                        NSLog(@"Connected to GCM (registration)");
                        [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeGCMConnectedNotification object:nil userInfo:nil];
                    }
                }];
            }
            
            NSDictionary *userInfo = @{@"registrationToken": registrationToken};
            [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeGCMTokenUpdatedNotification
                                                                object:nil
                                                              userInfo:userInfo];
        } else {
            NSLog(@"Registration to GCM failed with error: %@", error.localizedDescription);
            NSDictionary *userInfo = @{@"error": error.localizedDescription};
            [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeGCMTokenUpdatedNotification
                                                                object:nil
                                                              userInfo:userInfo];
        }
    };
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = self;
    // Start the GGLInstanceID shared instance with the that config and request a registration
    // token to enable reception of notifications
    [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];
#ifdef DEBUG
    BOOL isBuiltDebug = YES;
    NSLog(@"Starting GCM in development mode");
#else
    BOOL isBuiltDebug = NO;
    NSLog(@"Starting GCM in production mode");
#endif
    _registrationOptions = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                             kGGLInstanceIDAPNSServerTypeSandboxOption:@(isBuiltDebug)};
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:_registrationHandler];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Registration for remote notification failed with error: %@", error.localizedDescription);
    NSDictionary *userInfo = @{@"error": error.localizedDescription};
    [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeGCMTokenUpdatedNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Remote notification received 1: %@", userInfo);
    // This works only if the app started the GCM service
    [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
    
    [self handleNotification:userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeGCMMessageReceivedNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    NSLog(@"Remote notification received 2: %@", userInfo);
    
    // This works only if the app started the GCM service
    [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
    
    // If the application received the notification on the background or foreground
    if (application.applicationState != UIApplicationStateInactive) {
        if ([self handleNotification:userInfo]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeGCMMessageReceivedNotification
                                                                object:nil
                                                              userInfo:userInfo];
            
            handler(UIBackgroundFetchResultNewData);
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeGCMMessageReceivedNotification
                                                                object:nil
                                                              userInfo:userInfo];
            handler(UIBackgroundFetchResultNoData);
        }
    }
    // If the app is opening through the notification
    else {
        [self setActiveScreenAccordingToNotification:userInfo];
        handler(UIBackgroundFetchResultNewData);
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"Opening app from local notification");
        [self setActiveScreenAccordingToNotification:notification.userInfo];
    }
}

- (void)onTokenRefresh {
    // A rotation of the registration tokens is happening, so the app needs to request a new token.
    NSLog(@"The GCM registration token needs to be refreshed.");
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:_registrationHandler];
}

- (void)updateUserGCMToken:(NSString *)token {
    NSDictionary *params = @{@"token": token ? token : [NSNull null]};
    [CaronaeAPIHTTPSessionManager.instance PUT:@"/user/saveGcmToken" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"User's GCM token updated.");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error updating user's GCM token: %@", error.localizedDescription);
    }];
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
