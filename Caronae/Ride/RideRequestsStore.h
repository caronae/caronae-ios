@import Foundation;

@class Ride;

@interface RideRequestsStore : NSObject

/**
 *  Check if the user has already requested to join a Ride.
 *  @param ride The ride of the query.
 *  @return `YES` if the use has already requested to join the ride, `NO` otherwise.
 */
+ (BOOL)hasRequestedToJoinRide:(Ride *)ride;

/**
 *  Mark a Ride as already requested.
 * @param ride The ride the user has requested to join.
 */
+ (void)setRideAsRequested:(Ride *)ride;

/**
 *  Removes all join requests from cache.
 */
+ (void)clearAllRequests;

@end
