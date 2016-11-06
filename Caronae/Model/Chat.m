#import "Chat.h"
#import <Firebase.h>

@implementation Chat

- (instancetype)initWithRide:(Ride *)ride {
    self = [super init];
    if (self) {
        _ride = ride;
        _topicID = [Chat topicIDwithRideID:@(ride.rideID)];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CaronaeGCMConnectedNotification object:nil];
}

+ (NSString *)topicIDwithRideID:(NSNumber *)rideID {
    if (!rideID) {
        return @"";
    }
    return [NSString stringWithFormat:@"/topics/%lu", [rideID longValue]];
}

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
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)subscribe {
    NSLog(@"Subscribing to: %@", self.topicID);
    [[FIRMessaging messaging] subscribeToTopic:self.topicID];
    //self.subscribed = YES;
}

- (void)unsubscribe {
    NSLog(@"Unsubscribing from: %@", self.topicID);
    [[FIRMessaging messaging] unsubscribeFromTopic:self.topicID];
    //self.subscribed = NO;
}

+ (void)subscribeToTopicID:(NSString *)topicID {
    NSLog(@"Subscribing to: %@", topicID);
    [[FIRMessaging messaging] subscribeToTopic:topicID];
}

@end
