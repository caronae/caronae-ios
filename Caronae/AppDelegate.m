#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <CRToast/CRToast.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Google/CloudMessaging.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "AppDelegate.h"
#import "ChatStore.h"
#import "ChatViewController.h"
#import "Message.h"
#import "Message+CoreDataProperties.h"
#import "Notification.h"
#import "Notification+CoreDataProperties.h"

@interface AppDelegate () <GGLInstanceIDDelegate, GCMReceiverDelegate>
@property (nonatomic, strong) void (^registrationHandler) (NSString *registrationToken, NSError *error);
@property (nonatomic, assign) BOOL connectedToGCM;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.75f]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
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
        if (registrationToken != nil) {
            NSLog(@"Registration Token: %@", registrationToken);
            
            NSString *cachedRegistrationToken = [CaronaeDefaults userGCMToken];
            // Update cached registration token locally and remotely if the token has changed.
            if (![cachedRegistrationToken isEqualToString:registrationToken]) {
                [CaronaeDefaults setUserGCMToken:registrationToken];
                if ([CaronaeDefaults defaults].user) {
                    [weakSelf updateUserGCMToken:registrationToken];
                }
            }
            
            if (!weakSelf.connectedToGCM) {
                [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
                    if (error && error.code != kGCMServiceErrorCodeAlreadyConnected) {
                        NSLog(@"Could not connect to GCM (registration): %@", error.localizedDescription);
                    } else if (!error) {
                        weakSelf.connectedToGCM = true;
                        NSLog(@"Connected to GCM (registration)");
                    }
                }];
            }
            
            NSDictionary *userInfo = @{@"registrationToken": registrationToken};
            [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeGCMTokenUpdatedNotification
                                                                object:nil
                                                              userInfo:userInfo];
        } else {
            [CaronaeDefaults setUserGCMToken:nil];
            NSLog(@"Registration to GCM failed with error: %@", error.localizedDescription);
            NSDictionary *userInfo = @{@"error": error.localizedDescription};
            [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeGCMTokenUpdatedNotification
                                                                object:nil
                                                              userInfo:userInfo];
        }
    };
    
    [CRToastManager setDefaultOptions:@{
                                        kCRToastBackgroundColorKey: [UIColor colorWithRed:0.114 green:0.655 blue:0.365 alpha:1.000],
                                        }];
    
    [application setApplicationIconBadgeNumber:0];
    
    // Load home screen if the user has already signed in
    if ([CaronaeDefaults defaults].user) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeTabViewController"];
        self.window.rootViewController = initialViewController;
        [self.window makeKeyAndVisible];
        [CaronaeDefaults registerForNotifications];
    }
    
    return YES;
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
    if ([CaronaeDefaults userGCMToken] && !_connectedToGCM) {
        [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
            if (error && error.code != kGCMServiceErrorCodeAlreadyConnected) {
                NSLog(@"Could not connect to GCM (applicationDidBecomeActive): %@", error.localizedDescription);
            } else if (!error) {
                _connectedToGCM = true;
                NSLog(@"Connected to GCM (applicationDidBecomeActive)");
            }
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


#pragma mark - Etc

- (UIViewController *)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
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

- (BOOL)application:(UIApplication *)application handleNotification:(NSDictionary *)userInfo {
    if (!userInfo[@"msgType"]) return NO;
    
    NSString *msgType = userInfo[@"msgType"];
    
    // Handle chat messages
    if ([msgType isEqualToString:@"chat"]) {
        int senderId = [userInfo[@"senderId"] intValue];
        int currentUserId = [[CaronaeDefaults defaults].user[@"id"] intValue];
        // We don't need to handle a message if it's from the logged user
        if (senderId == currentUserId) {
            return NO;
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
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            return YES;
        }
        
        
        NSString *notificationBody = [NSString stringWithFormat:@"%@: %@", message.senderName, message.text];
        if (application.applicationState != UIApplicationStateActive) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = message.sentDate;
            notification.alertBody = notificationBody;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            
        }
        else {
            ChatViewController *topVC = (ChatViewController *)[self topViewController];
            // Ignore notification if the message's chat is already open
            if ([topVC isKindOfClass:ChatViewController.class] && [message.rideID isEqualToNumber:@(topVC.chat.ride.rideID)]) {
                return YES;
            }
            
            [CRToastManager showNotificationWithOptions:@{kCRToastTextKey: notificationBody}                                     completionBlock:nil];
        }
        
        Notification *caronaeNotification = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(Notification.class) inManagedObjectContext:context];
        caronaeNotification.rideID = rideID;
        caronaeNotification.date = message.sentDate;
        caronaeNotification.type = msgType;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save notification: %@", [error localizedDescription]);
            return YES;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeDidUpdateNotifications
                                                            object:nil
                                                          userInfo:userInfo];
        
        return YES;
    }
    // Handle 'join request accepted' messages
    else if ([msgType isEqualToString:@"accepted"]) {
        NSNumber *rideID = @([userInfo[@"rideId"] intValue]);
        
        [Chat subscribeToTopicID:[Chat topicIDwithRideID:rideID]];
    }
    
    [CRToastManager showNotificationWithOptions:@{kCRToastTextKey: userInfo[@"message"]}                                     completionBlock:nil];
    
    return YES;
}


#pragma mark - Google Cloud Messaging (GCM)

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = self;
    // Start the GGLInstanceID shared instance with the that config and request a registration
    // token to enable reception of notifications
    [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];
#ifdef DEBUG
    BOOL isBuiltDebug = YES;
    NSLog(@"Starting GCM in sandbox mode");
#else
    BOOL isBuiltDebug = NO;
    NSLog(@"Starting GCM in appstore mode");
#endif
    _registrationOptions = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                             kGGLInstanceIDAPNSServerTypeSandboxOption:@(isBuiltDebug)}; // FIXME
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
    NSLog(@"Notification received 1: %@", userInfo);
    // This works only if the app started the GCM service
    [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
    
    [self application:application handleNotification:userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeGCMMessageReceivedNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    NSLog(@"Notification received 2: %@", userInfo);
    
    // This works only if the app started the GCM service
    [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
    
    // If the application received the notification on the background or foreground
    if (application.applicationState != UIApplicationStateInactive) {
        if ([self application:application handleNotification:userInfo]) {
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
    // If the application is opening through the notification
    else {
        // TODO: open view according to notification type
        handler(UIBackgroundFetchResultNoData);
    }
}

- (void)onTokenRefresh {
    // A rotation of the registration tokens is happening, so the app needs to request a new token.
    NSLog(@"The GCM registration token needs to be changed.");
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:_registrationHandler];
}

- (void)updateUserGCMToken:(NSString *)token {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    NSDictionary *params = @{@"token": token ? token : [NSNull null]};
    [manager PUT:[CaronaeAPIBaseURL stringByAppendingString:@"/user/saveGcmToken"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"User's GCM token updated.");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error updating user's GCM token: %@", error.localizedDescription);
    }];
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.meriw.Caronae" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Caronae" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Caronae.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                               NSInferMappingModelAutomaticallyOption : @(YES) };

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
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
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
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
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
