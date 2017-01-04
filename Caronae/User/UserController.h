#import <Foundation/Foundation.h>

@class User, Ride;

@interface UserController : NSObject

+ (instancetype _Nonnull)sharedInstance;
@property (nonatomic, readonly) NSString *_Nullable userToken;
@property (nonatomic, readwrite) NSString *_Nullable userGCMToken;
@property (nonatomic, readonly) NSString *_Nullable userFBToken;

@end
