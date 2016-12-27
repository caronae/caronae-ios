#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

- (void)updateApplicationBadgeNumber;

@property (strong, nonatomic) UIWindow *window;

// Notification support
- (BOOL)handleNotification:(NSDictionary *)userInfo;
- (void)setActiveScreenAccordingToNotification:(NSDictionary *)userInfo;

// Core Data support
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)deleteAllObjects:(NSString *)entityDescription;
- (NSURL *)applicationDocumentsDirectory;

// Etc.
- (UIViewController *)topViewController;

@end

