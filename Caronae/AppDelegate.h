@import UIKit;
@import CoreData;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Notification support
- (void)setActiveScreenAccordingToNotification:(NSDictionary *)userInfo;

// Core Data support
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)deleteAllObjects:(NSString *)entityDescription;
- (NSURL *)applicationDocumentsDirectory;

@end

