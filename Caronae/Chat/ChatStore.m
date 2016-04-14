#import "ChatStore.h"

static NSMutableDictionary<NSNumber *, Chat *> *chats;

@implementation ChatStore

+ (void)setChat:(Chat *)chat forRide:(Ride *)ride {
    if (!chat || !ride || ride.rideID <= 0) {
        NSLog(@"Tried to store a Chat with an invalid parameter (Chat: %@, Ride: %@)", chat, ride);
        return;
    }
    
    NSNumber *key = [NSNumber numberWithLong:ride.rideID];
    
    @synchronized (chats) {
        if (!chats) {
            chats = [[NSMutableDictionary alloc] init];
        }
        
        if (chats) {
            chats[key] = chat;
        }
    }
}

+ (Chat *)chatForRide:(Ride *)ride {
    if (!ride || ride.rideID <= 0) return nil;
    
    NSNumber *key = [NSNumber numberWithLong:ride.rideID];
    
    @synchronized (chats) {
        if (!chats) return nil;
        return chats[key];
    }
}

+ (NSDictionary<NSNumber *, Chat *> *)allChats {
    @synchronized (chats) {
        return chats;
    }
}

+ (void)clearChats {
    @synchronized (chats) {
        if (chats) [chats removeAllObjects];
    }
}

@end
