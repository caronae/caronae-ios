#import "RideRequestsStore.h"
#import "Caronae-Swift.h"

@implementation RideRequestsStore

+ (BOOL)hasRequestedToJoinRide:(Ride *)ride {
    NSArray *requested = [RideRequestsStore cachedRequests];
    NSNumber *rideID = @(ride.id);
    return [requested containsObject:rideID];
}

+ (void)setRideAsRequested:(Ride *)ride {
    NSMutableArray *requests = [RideRequestsStore cachedRequests].mutableCopy;
    NSNumber *rideID = @(ride.id);
    [requests addObject:rideID];
    [RideRequestsStore saveCachedRequests:requests];
}

+ (void)clearAllRequests {
    [RideRequestsStore saveCachedRequests:nil];
}

+ (NSArray *)cachedRequests {
    NSArray *requests = [[NSUserDefaults standardUserDefaults] arrayForKey:@"cachedJoinRequests"];
    if (!requests) {
        requests = [[NSArray alloc] init];
        [RideRequestsStore saveCachedRequests:requests];
    }
    return requests;
}

+ (void)saveCachedRequests:(NSArray *)cachedRequests {
    [[NSUserDefaults standardUserDefaults] setObject:cachedRequests forKey:@"cachedJoinRequests"];
}

@end
