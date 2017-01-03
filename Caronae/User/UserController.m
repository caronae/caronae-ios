#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AppDelegate.h"
#import "ChatStore.h"
#import "NSDictionary+dictionaryWithoutNulls.h"
#import "RideRequestsStore.h"
#import "UserController.h"
#import "Caronae-Swift.h"

@implementation UserController

static NSUserDefaults *userDefaults;

+ (instancetype)sharedInstance {
    static UserController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        userDefaults = [NSUserDefaults standardUserDefaults];
    });
    return sharedInstance;
}

- (void)setUser:(User *)user token:(NSString *)userToken rides:(NSArray<Ride *> *)userRides {
    self.user = user;
    self.userToken = userToken;
    self.userRides = userRides;
}

- (User *)user {
    NSError *error;
    NSDictionary *userJSON = [userDefaults dictionaryForKey:@"user"];
    
    // TODO: load from disk
    User *user = nil;
    if (error) {
        NSLog(@"Error deserializing user from defaults. %@", error.localizedDescription);
    }
    
    return user;
}

- (void)setUser:(User *)user {
    if (user) {
        NSError *error;
        // TODO: serialize and persist
        NSDictionary *userJSON = nil;
        
        if (!error) {
            [userDefaults setObject:userJSON forKey:@"user"];
        }
        else {
            NSLog(@"Error serializing user. %@", error.localizedDescription);
        }
    }
    else {
        [userDefaults removeObjectForKey:@"user"];
    }
    
    [userDefaults synchronize];
}

- (void)signOut {
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    // Clear chats
    NSDictionary *chats = [ChatStore allChats];
    for (id rideID in chats) {
        [chats[rideID] unsubscribe];
    }
    [ChatStore clearChats];
    
    // Clear saved notifications
    [appDelegate deleteAllObjects:@"Notification"];
    
    // Clear user data
    self.userGCMToken = nil;
    [appDelegate updateUserGCMToken:nil];
    self.user = nil;
    self.userToken = nil;
    [RideRequestsStore clearAllRequests];
    [[[FBSDKLoginManager alloc] init] logOut];
    
    [appDelegate updateApplicationBadgeNumber];
    
    UIViewController *topViewController = [appDelegate topViewController];
    UIViewController *authViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"InitialTokenScreen"];
    authViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [topViewController presentViewController:authViewController animated:YES completion:nil];
}

- (NSString *)userFBToken {
    return [FBSDKAccessToken currentAccessToken].tokenString;
}

- (NSString *)userGCMToken {
    return [userDefaults stringForKey:@"gcmToken"];
}

- (void)setUserGCMToken:(NSString *)gcmToken {
    [userDefaults setObject:gcmToken forKey:@"gcmToken"];
    [userDefaults synchronize];
}

- (NSString *)userToken {
    return [userDefaults objectForKey:@"token"];
}

- (void)setUserToken:(NSString *)userToken {
    [userDefaults setObject:userToken forKey:@"token"];
    [userDefaults synchronize];
}

- (NSArray<Ride *> *)userRides {
    return [userDefaults arrayForKey:@"userCreatedRides"];
}

- (void)setUserRides:(NSArray<Ride *> *)userRides {
    [userDefaults setObject:userRides forKey:@"userCreatedRides"];
    [userDefaults synchronize];
}

@end
