#import <Foundation/Foundation.h>

extern NSString *const CaronaeAPIBaseURL;

extern NSString *const CaronaeUserRidesUpdatedNotification;

extern NSString *const CaronaeErrorDomain;
extern const NSInteger CaronaeErrorInvalidResponse;
extern const NSInteger CaronaeErrorNoRidesCreated;

@interface CaronaeDefaults : NSObject

+ (instancetype)defaults;

@property (nonatomic, readonly) NSArray *centers;
@property (nonatomic, readonly) NSArray *hubs;

@end