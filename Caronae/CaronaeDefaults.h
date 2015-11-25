#import <Foundation/Foundation.h>

extern const NSString *CaronaeAPIBaseURL;

extern NSString *CaronaeErrorDomain;
extern const NSInteger CaronaeErrorInvalidResponse;
extern const NSInteger CaronaeErrorNoRidesCreated;

@interface CaronaeDefaults : NSObject

+ (instancetype)defaults;

@property (nonatomic, readonly) NSArray *centers;
@property (nonatomic, readonly) NSArray *hubs;

@end