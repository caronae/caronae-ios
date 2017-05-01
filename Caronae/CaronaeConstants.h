@import UIKit;

#pragma mark - Static pages URLs

extern NSString *const CaronaeIntranetURLString;
extern NSString *const CaronaeAboutPageURLString;
extern NSString *const CaronaeTermsOfUsePageURLString;
extern NSString *const CaronaeFAQPageURLString;


#pragma mark - Preference keys

extern NSString *const CaronaePreferenceLastSearchedZoneKey;
extern NSString *const CaronaePreferenceLastSearchedNeighborhoodsKey;
extern NSString *const CaronaePreferenceLastSearchedCenterKey;
extern NSString *const CaronaePreferenceLastSearchedDateKey;

extern NSString *const CaronaePreferenceFilterIsEnabledKey;
extern NSString *const CaronaePreferenceLastFilteredZoneKey;
extern NSString *const CaronaePreferenceLastFilteredNeighborhoodsKey;
extern NSString *const CaronaePreferenceLastFilteredCentersKey;


#pragma mark - Notifications

extern NSNotificationName const CaronaeNotificationReceivedNotification;
extern NSNotificationName const CaronaeDidUpdateNotifications;
extern NSNotificationName const CaronaeDidUpdateUserNotification;


#pragma mark - Etc.

extern NSString *const CaronaeErrorDomain;
extern NSString *const CaronaeSignOutRequiredKey;
extern NSString *const Caronae8PhoneNumberPattern;
extern NSString *const Caronae9PhoneNumberPattern;
extern NSString *const CaronaePlaceholderProfileImage;
extern NSString *const CaronaeSearchDateFormat;
extern NSString *const CaronaeDateLocaleIdentifier;
extern NSString *const CaronaeAllNeighborhoodsText;
extern NSString *const CaronaeAllHubsText;


@interface CaronaeConstants : NSObject

+ (instancetype)defaults;

+ (UIColor *)colorForZone:(NSString *)zone;

@property (nonatomic, readonly) NSArray *campuses;
@property (nonatomic, readonly) NSDictionary *campusColors;
@property (nonatomic, readonly) NSDictionary *centers;
@property (nonatomic, readonly) NSDictionary *hubs;

@property (nonatomic, readonly) NSArray *zones;
@property (nonatomic, readonly) NSDictionary *zoneColors;
@property (nonatomic, readonly) NSDictionary *neighborhoods;

@end
