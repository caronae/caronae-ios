#import <UIKit/UIKit.h>

extern NSString *const CaronaeAPIBaseURL;
extern NSString *const CaronaeGCMAPISendURL;
extern NSString *const CaronaeGCMAPIKey;

extern NSString *const CaronaeIntranetURLString;
extern NSString *const CaronaeAboutPageURLString;
extern NSString *const CaronaeTermsOfUsePageURLString;

extern NSString *const CaronaeGCMConnectedNotification;
extern NSString *const CaronaeGCMTokenUpdatedNotification;
extern NSString *const CaronaeGCMMessageReceivedNotification;
extern NSString *const CaronaeDidUpdateNotifications;

extern NSString *const CaronaeErrorDomain;
extern const NSInteger CaronaeErrorInvalidResponse;
extern const NSInteger CaronaeErrorNoRidesCreated;
extern const NSInteger CaronaeErrorOpeningCoreDataStore;

extern NSString *const Caronae8PhoneNumberPattern;
extern NSString *const Caronae9PhoneNumberPattern;
extern NSString *const CaronaePlaceholderProfileImage;

@interface CaronaeDefaults : NSObject

+ (instancetype)defaults;

+ (UIColor *)colorForZone:(NSString *)zone;

@property (nonatomic, readonly) NSArray *centers;
@property (nonatomic, readonly) NSArray *hubs;
@property (nonatomic, readonly) NSArray *zones;
@property (nonatomic, readonly) NSDictionary *zoneColors;
@property (nonatomic, readonly) NSDictionary *neighborhoods;

@end
