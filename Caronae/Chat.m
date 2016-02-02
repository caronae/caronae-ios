#import "Chat.h"

@implementation Chat

- (BOOL)subscribed {
    NSNumber *rideId = @(self.ride.rideID);
    NSArray *subscribedTopics = [[NSUserDefaults standardUserDefaults] arrayForKey:@"subscribedTopics"];
    return [subscribedTopics containsObject:rideId];
}

- (void)setSubscribed:(BOOL)subscribed {
    NSNumber *rideId = @(self.ride.rideID);
    NSArray *subscribedTopics = [[NSUserDefaults standardUserDefaults] arrayForKey:@"subscribedTopics"];
    
    // Save subscribed
    if (subscribed) {
        // If subscribed topics were not previously created, init with the current ride
        if (!subscribedTopics) {
            subscribedTopics = @[rideId];
        }
        // If it already exists, check if it doesn't already contain object and add it
        else if (![subscribedTopics containsObject:rideId]) {
            subscribedTopics = [subscribedTopics arrayByAddingObject:rideId];
        }
    }
    // Delete subscribed
    else {
        if ([subscribedTopics containsObject:rideId]) {
            NSMutableArray *newSubscribedTopics = [NSMutableArray arrayWithArray:subscribedTopics];
            [newSubscribedTopics removeObject:rideId];
            subscribedTopics = newSubscribedTopics;
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:subscribedTopics forKey:@"subscribedTopics"];
}

@end
