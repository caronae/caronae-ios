@import Google;
#import "Chat.h"
#import "Caronae-Swift.h"

@implementation Chat

- (instancetype)initWithRide:(Ride *)ride {
    self = [super init];
    if (self) {
        _ride = ride;
        _topicID = [Chat topicIDwithRideID:@(ride.id)];
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
    NSNumber *rideId = @(self.ride.id);
    NSArray *subscribedTopics = [[NSUserDefaults standardUserDefaults] arrayForKey:@"subscribedTopics"];
    return [subscribedTopics containsObject:rideId];
}

- (void)setSubscribed:(BOOL)subscribed {
    NSNumber *rideId = @(self.ride.id);
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
    NSString *registrationToken = UserService.instance.userGCMToken;
    if (registrationToken) {
        [[GCMPubSub sharedInstance] subscribeWithToken:registrationToken
                                                 topic:self.topicID
                                               options:nil
                                               handler:^(NSError *error) {
                                                   if (error) {
                                                       if (error.code == kGCMServiceErrorCodePubSubAlreadySubscribed) {
                                                           self.subscribed = YES;
                                                           NSLog(@"Already subscribed to %@",
                                                                 self.topicID);
                                                       } else {
                                                           NSLog(@"Subscription failed: %@",
                                                                 error.localizedDescription);
                                                       }
                                                   } else {
                                                       self.subscribed = YES;
                                                       NSLog(@"Subscribed to %@", self.topicID);
                                                   }
                                               }];
        
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectWithGCM) name:CaronaeGCMConnectedNotification object:nil];
        NSLog(@"Could not subscribe to topic because registration token is nil. Waiting for GCM to connect...");
    }
}

- (void)unsubscribe {
    NSString *registrationToken = UserService.instance.userGCMToken;
    if (registrationToken) {
        [[GCMPubSub sharedInstance] unsubscribeWithToken:registrationToken
                                                   topic:self.topicID
                                                 options:nil
                                                 handler:^(NSError *error) {
                                                     if (error) {
                                                         if (error.code == kGCMServiceErrorCodePubSubAlreadyUnsubscribed) {
                                                             self.subscribed = NO;
                                                             NSLog(@"Already unsubscribed from %@",
                                                                   self.topicID);
                                                         } else {
                                                             NSLog(@"Failed to unsubscribe: %@",
                                                                   error.localizedDescription);
                                                         }
                                                     } else {
                                                         self.subscribed = NO;
                                                         NSLog(@"Unsubscribed from %@", self.topicID);
                                                     }
                                                 }];
        
    }
    else {
        NSLog(@"Could not unsubscribe from topic because registration token is nil");
    }
}

+ (void)subscribeToTopicID:(NSString *)topicID {
    NSString *registrationToken = UserService.instance.userGCMToken;
    if (registrationToken) {
        [[GCMPubSub sharedInstance] subscribeWithToken:registrationToken
                                                 topic:topicID
                                               options:nil
                                               handler:^(NSError *error) {
                                                   if (error) {
                                                       if (error.code == kGCMServiceErrorCodePubSubAlreadySubscribed) {
                                                           NSLog(@"Already subscribed to %@",
                                                                 topicID);
                                                       } else {
                                                           NSLog(@"Subscription failed: %@",
                                                                 error.localizedDescription);
                                                       }
                                                   } else {
                                                       NSLog(@"Subscribed to %@", topicID);
                                                   }
                                               }];
        
    }
    else {
        NSLog(@"Could not subscribe to topic because registration token is nil");
    }
}

- (void)didConnectWithGCM {
    NSLog(@"GCM connected. Trying to subscribe to topic %@ again...", self.topicID);
    [self subscribe];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CaronaeGCMConnectedNotification object:nil];
}

@end
