#import <UIKit/UIKit.h>

extern NSString *const CaronaeAPIBaseURL;

extern NSString *const CaronaeUserRidesUpdatedNotification;

extern NSString *const CaronaeErrorDomain;
extern const NSInteger CaronaeErrorInvalidResponse;
extern const NSInteger CaronaeErrorNoRidesCreated;

@interface CaronaeDefaults : NSObject

+ (instancetype)defaults;

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
@property (nonatomic, readwrite) NSDictionary *user;
@property (nonatomic, readwrite) NSString *userToken;

@end