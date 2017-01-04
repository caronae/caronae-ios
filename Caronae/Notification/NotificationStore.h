@import Foundation;
#import "Notification.h"

typedef enum {
    NotificationTypeAll,
    NotificationTypeChat,
    NotificationTypeRequest
} NotificationType;

@interface NotificationStore : NSObject

+ (BOOL)insertNotification:(Notification *)notification;

+ (NSArray<Notification *> *)getNotificationsOfType:(NotificationType)type;

+ (void)clearNotificationsForRide:(NSNumber *)rideID ofType:(NotificationType)type;

@end
