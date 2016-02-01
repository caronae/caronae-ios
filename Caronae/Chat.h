#import <Foundation/Foundation.h>
#import "Ride.h"

@interface Chat : NSObject

@property (nonatomic) Ride *ride;
@property (nonatomic) NSArray *loadedMessages;

@end
