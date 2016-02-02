#import <UIKit/UIKit.h>
#import "Ride.h"

@interface Chat : NSObject

@property (nonatomic) Ride *ride;
@property (nonatomic) NSArray *loadedMessages;
@property (nonatomic) UIColor *color;
@property (nonatomic) BOOL subscribed;

@end
