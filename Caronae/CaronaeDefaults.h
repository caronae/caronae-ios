#import <UIKit/UIKit.h>

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

extern NSString *const CaronaePhoneNumberPattern;

@interface CaronaeDefaults : NSObject

+ (instancetype)defaults;

/**
 *  Registers for push notifications with iOS. If the user has already registered for notifications,
 * this does nothing.
 */
+ (void)registerForNotifications;

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

@end