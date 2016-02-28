#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Notification : NSManagedObject

+ (instancetype)notificationWithRideID:(NSNumber *)rideID date:(NSDate *)date type:(NSString *)type context:(NSManagedObjectContext *)managedObjectContext;

@end

NS_ASSUME_NONNULL_END

#import "Notification+CoreDataProperties.h"
