#import "AppDelegate.h"
#import "NotificationStore.h"

NSString *NSStringFromNotificationType(NotificationType type) {
    switch (type) {
        case NotificationTypeChat:
            return @"chat";
        case NotificationTypeRequest:
            return @"joinRequest";
        default:
            return nil;
    }
}

static NSManagedObjectContext *_managedObjectContext;

@implementation NotificationStore

+ (BOOL)insertNotification:(Notification *)notification {
    NSManagedObjectContext *managedObjectContext = [NotificationStore managedObjectContext];
        
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save notification: %@", error.localizedDescription);
        return NO;
    }
    
    [NotificationStore notifyListenersThatNotificationsChanged];
    return YES;
}

+ (NSArray<Notification *> *)getNotificationsOfType:(NotificationType)type {
    NSManagedObjectContext *managedObjectContext = [NotificationStore managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(Notification.class) inManagedObjectContext:managedObjectContext];
    fetchRequest.entity = entity;
    
    if (type != NotificationTypeAll) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type = %@", NSStringFromNotificationType(type)];
    }
    
    NSError *error;
    NSArray<Notification *> *notifications = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Whoops, couldn't load unread notifications: %@", error.localizedDescription);
        return nil;
    }
    return notifications;
}

+ (void)clearNotificationsForRide:(NSNumber *)rideID ofType:(NotificationType)type {
    NSManagedObjectContext *managedObjectContext = [NotificationStore managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(Notification.class) inManagedObjectContext:managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.includesPropertyValues = NO;
    
    NSPredicate *predicate;
    if (type == NotificationTypeAll) {
        predicate = [NSPredicate predicateWithFormat:@"rideID = %@", rideID];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"rideID = %@ AND type = %@", rideID, NSStringFromNotificationType(type)];
    }
    fetchRequest.predicate = predicate;
    
    NSError *error;
    NSArray<Notification *> *unreadNotifications = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Whoops, couldn't load notifications for ride: %@", error.localizedDescription);
        return;
    }
    
    for (id notification in unreadNotifications) {
        [managedObjectContext deleteObject:notification];
    }
    
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't delete notifications for ride: %@", error.localizedDescription);
        return;
    }
    
    [NotificationStore notifyListenersThatNotificationsChanged];
}

+ (void)notifyListenersThatNotificationsChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeDidUpdateNotifications object:nil userInfo:nil];
}

+ (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

@end
