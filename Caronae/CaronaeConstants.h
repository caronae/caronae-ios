@import UIKit;

#pragma mark - API settings

extern NSString *const CaronaeAPIBaseURL;


#pragma mark - Static pages URLs

extern NSString *const CaronaeIntranetURLString;
extern NSString *const CaronaeAboutPageURLString;
extern NSString *const CaronaeTermsOfUsePageURLString;


#pragma mark - Preference keys

extern NSString *const CaronaePreferenceLastSearchedNeighborhoodsKey;
extern NSString *const CaronaePreferenceLastSearchedCenterKey;
extern NSString *const CaronaePreferenceLastSearchedDateKey;


#pragma mark - Notifications

extern NSNotificationName const CaronaeNotificationReceivedNotification;
extern NSNotificationName const CaronaeDidUpdateNotifications;
extern NSNotificationName const CaronaeDidUpdateUserNotification;


#pragma mark - Error types

extern NSString *const CaronaeErrorDomain;
extern const NSInteger CaronaeErrorInvalidResponse;
extern const NSInteger CaronaeErrorNoRidesCreated;
extern const NSInteger CaronaeErrorUserNotLoggedInWithFacebook;


#pragma mark - Etc.

extern NSString *const Caronae8PhoneNumberPattern;
extern NSString *const Caronae9PhoneNumberPattern;
extern NSString *const CaronaePlaceholderProfileImage;
extern NSString *const CaronaeSearchDateFormat;
extern NSString *const CaronaeDateLocaleIdentifier;


@interface CaronaeConstants : NSObject

+ (instancetype)defaults;

+ (UIColor *)colorForZone:(NSString *)zone;

@property (nonatomic, readonly) NSArray *centers;
@property (nonatomic, readonly) NSArray *hubs;
@property (nonatomic, readonly) NSArray *zones;
@property (nonatomic, readonly) NSDictionary *zoneColors;
@property (nonatomic, readonly) NSDictionary *neighborhoods;

@end
