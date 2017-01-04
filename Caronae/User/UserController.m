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

@end
