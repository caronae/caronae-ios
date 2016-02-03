#import <UIKit/UIKit.h>
#import "Ride.h"

@interface Chat : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRide:(Ride *)ride NS_DESIGNATED_INITIALIZER;

- (void)subscribeToTopic;

@property (nonatomic) Ride *ride;
@property (nonatomic, readonly) NSString *topicID;
@property (nonatomic) NSArray *loadedMessages;
@property (nonatomic) BOOL subscribed;

@end
