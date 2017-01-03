#import <Foundation/Foundation.h>

@class User, Ride;

@interface UserController : NSObject

+ (instancetype _Nonnull)sharedInstance;

/**
 *  Stores the logged in user object, token and previous rides.
 *
 *  @param user A User object containing the signed in user profile.
 *  @param userToken   The user's authentication token.
 *  @param userRides   An array of ride dictionaries.
 */
- (void)setUser:(User *_Nullable)user token:(NSString *_Nullable)userToken rides:(NSArray<Ride *> *_Nullable)userRides;

/**
 *  Signs out current user and presents the authentication screen modally.
 */
- (void)signOut;

@property (nonatomic, readwrite) User *_Nullable user;
@property (nonatomic, readonly) NSString *_Nullable userToken;
@property (nonatomic, readwrite) NSString *_Nullable userGCMToken;
@property (nonatomic, readonly) NSString *_Nullable userFBToken;
@property (nonatomic, readwrite) NSArray<Ride *> *_Nullable userRides;

@end
