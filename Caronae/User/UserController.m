#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AppDelegate.h"
#import "ChatStore.h"
#import "NSDictionary+dictionaryWithoutNulls.h"
#import "RideRequestsStore.h"
#import "UserController.h"

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
    
    User *user = [MTLJSONAdapter modelOfClass:User.class fromJSONDictionary:userJSON error:&error];
    if (error) {
        NSLog(@"Error deserializing user from defaults. %@", error.localizedDescription);
    }
    
    return user;
}

- (void)setUser:(User *)user {
    if (user) {
        NSError *error;
        NSDictionary *userJSON = [[MTLJSONAdapter JSONDictionaryFromModel:user error:&error] dictionaryWithoutNulls];
        
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
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
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
