#import <UIKit/UIKit.h>

#import "Ride.h"
#import "User.h"

extern NSString *const CaronaeAPIBaseURL;
extern NSString *const CaronaeGCMAPISendURL;
extern NSString *const CaronaeGCMAPIKey;

extern NSString *const CaronaeAboutPageURLString;
extern NSString *const CaronaeTermsOfUsePageURLString;
extern NSString *const CaronaeFAQPageURLString;

extern NSString *const CaronaeGCMConnectedNotification;
extern NSString *const CaronaeGCMTokenUpdatedNotification;
extern NSString *const CaronaeGCMMessageReceivedNotification;
extern NSString *const CaronaeDidUpdateNotifications;

extern NSString *const CaronaeErrorDomain;
extern const NSInteger CaronaeErrorInvalidResponse;
extern const NSInteger CaronaeErrorNoRidesCreated;
extern const NSInteger CaronaeErrorOpeningCoreDataStore;

@interface CaronaeDefaults : NSObject

+ (instancetype)defaults;

/**
 *  Stores the user object, token and previous rides internally.
 *
 *  @param user A User object containing the signed in user profile.
 *  @param userToken   The user's authentication token.
 *  @param userRides   An array of ride dictionaries.
 */
+ (void)signIn:(User *)user token:(NSString *)userToken rides:(NSArray *)userRides;

/**
 *  Registers for push notifications with iOS. If the user has already registered for notifications,
 * this does nothing.
 */
+ (void)registerForNotifications;

/**
 *  Signs out current user and presents the authentication screen modally.
 */
+ (void)signOut;

/**
 *  Returns the user's Facebook access token.
 *
 *  @return A string containing the user's FB access token or `nil` if user is not connected with Facebook.
 */
+ (NSString *)userFBToken;

/**
 *  Return the user's GCM registration token.
 *
 *  @return A string containing the user's Google Cloud Messaging registration token or `nil` if there isn't one.
 */
+ (NSString *)userGCMToken;

/**
 *  Update the user's GCM token.
 *
 *  @param gcmToken A string containing the user's GCM token or `nil` if there isn`t one.
 */
+ (void)setUserGCMToken:(NSString *)gcmToken;

/**
 *  Check if the user profile is incomplete (with any fields left blank).
 *  Should be called to check if the user needs to be prompted with the screen
 *  to complete their profile.
 *
 *  @return YES if the user has any mandatory profile fields left blank. NO if
 *  the user has already completed his profile.
 */
+ (BOOL)userProfileIsIncomplete;

/**
 *  Check if the user has already requested to join a Ride.
 *  @param ride The ride of the query.
 *  @return `true` if the use has already requested to join the ride, `false` otherwise.
 */
+ (BOOL)hasUserAlreadyRequestedJoin:(Ride *)RIDE;

/**
 *  Adds a Ride to the join requests cache.
 * @param ride The ride the user has requested to join.
 */
+ (void)addToCachedJoinRequests:(Ride *)ride;

/**
 *  Returns the color related to a specific zone according to the app's default color palette.
 *
 *  @param zone The zone name (Zona Norte, Zona Sul, Centro etc.)
 *
 *  @return The color of the zone.
 */
+ (UIColor *)colorForZone:(NSString *)zone;

@property (nonatomic, readonly) NSArray *centers;
@property (nonatomic, readonly) NSArray *hubs;
@property (nonatomic, readonly) NSArray *zones;
@property (nonatomic, readonly) NSDictionary *zoneColors;
@property (nonatomic, readonly) NSDictionary *neighborhoods;
@property (nonatomic, readwrite) User *user;
@property (nonatomic, readwrite) NSString *userToken;
@property (nonatomic, readwrite) NSArray *cachedJoinRequests;

@end