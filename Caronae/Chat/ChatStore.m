#import "ChatStore.h"

static NSMutableDictionary<NSNumber *, Chat *> *chats;

@implementation ChatStore

+ (void)setChat:(Chat *)chat forRide:(Ride *)ride {
    if (!chat || !ride || ride.rideID <= 0) {
        NSLog(@"Tried to store a Chat with an invalid parameter (Chat: %@, Ride: %@)", chat, ride);
        return;
    }
    
    if (!chats) {
        chats = [[NSMutableDictionary alloc] init];
    }
    
    if (chats) {
        NSNumber *key = [NSNumber numberWithLong:ride.rideID];
        chats[key] = chat;
    }
}

+ (Chat *)chatForRide:(Ride *)ride {
    if (!chats || !ride || ride.rideID <= 0) return nil;
    NSNumber *key = [NSNumber numberWithLong:ride.rideID];
    if (!key) {
        return nil;
    }
    return chats[key];
}

+ (NSDictionary<NSNumber *, Chat *> *)allChats {
    return chats;
}

+ (void)clearChats {
    if (chats) [chats removeAllObjects];
}

@end
