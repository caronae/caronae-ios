#import <Foundation/Foundation.h>
#import "Chat.h"
#import "Ride.h"

@interface ChatStore : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Loads the chat for the corresponding ride in the store.
 *
 *  @param chat An initialised chat for the ride.
 *  @param ride A ride for the chat.
 */
+ (void)setChat:(Chat *)chat forRide:(Ride *)ride;

/**
 *  Returns the corresponding Chat object for a ride.
 *
 *  @param ride A ride for the chat.
 *  @return An initialised chat for the ride or `nil` if it's not defined.
 */
+ (Chat *)chatForRide:(Ride *)ride;

@end
