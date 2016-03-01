#import <Foundation/Foundation.h>
#import "Ride.h"
#import "User.h"

@interface UserController : NSObject

+ (instancetype)sharedInstance;

/**
 *  Stores the logged in user object, token and previous rides.
 *
 *  @param user A User object containing the signed in user profile.
 *  @param userToken   The user's authentication token.
 *  @param userRides   An array of ride dictionaries.
 */
- (void)setUser:(User *)user token:(NSString *)userToken rides:(NSArray<Ride *> *)userRides;

/**
 *  Signs out current user and presents the authentication screen modally.
 */
- (void)signOut;

@property (nonatomic, readwrite) User *user;
@property (nonatomic, readonly) NSString *userToken;
@property (nonatomic, readwrite) NSString *userGCMToken;
@property (nonatomic, readonly) NSString *userFBToken;
@property (nonatomic, readwrite) NSArray<Ride *> *userRides;

@end
