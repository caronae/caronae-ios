@import UIKit;

@class Ride;

@interface Chat : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRide:(Ride *)ride NS_DESIGNATED_INITIALIZER;

+ (NSString *)topicIDwithRideID:(NSNumber *)rideID;
+ (void)subscribeToTopicID:(NSString *)topicID;
- (void)subscribe;
- (void)unsubscribe;

@property (nonatomic) Ride *ride;
@property (nonatomic, readonly) NSString *topicID;
@property (nonatomic) NSArray *loadedMessages;
@property (nonatomic) BOOL subscribed;

@end
