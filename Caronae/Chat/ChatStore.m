#import "ChatStore.h"

static NSMutableDictionary<NSNumber *, Chat *> *chats;

@implementation ChatStore

+ (void)setChat:(Chat *)chat forRide:(Ride *)ride {
    if (!chat || !ride) {
        NSLog(@"Tried to store a Chat with a nil parameter (Chat: %@, Ride: %@)", chat, ride);
        return;
    }
    
    if (!chats) {
        chats = [[NSMutableDictionary alloc] init];
    }
    
    id key = @(ride.rideID);
    chats[key] = chat;
}

+ (Chat *)chatForRide:(Ride *)ride {
    if (!chats) return nil;
    id key = @(ride.rideID);
    return chats[key];
}

+ (NSDictionary<NSNumber *, Chat *> *)allChats {
    return chats;
}

+ (void)clearChats {
    if (chats) [chats removeAllObjects];
}

@end
