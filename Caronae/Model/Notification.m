#import "Notification.h"

@implementation Notification

+ (instancetype)notificationWithRideID:(NSNumber *)rideID date:(NSDate *)date type:(NSString *)type context:(NSManagedObjectContext *)managedObjectContext {
    Notification *notification = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(Notification.class) inManagedObjectContext:managedObjectContext];
    notification.rideID = rideID;
    notification.date = date;
    notification.type = type;
    return notification;
}

@end
