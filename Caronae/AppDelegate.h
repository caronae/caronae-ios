#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

- (void)updateApplicationBadgeNumber;
- (void)updateUserGCMToken:(NSString *)token;

@property (strong, nonatomic) UIWindow *window;

// GCM support
@property(nonatomic, readonly, strong) NSString *gcmSenderID;
@property(nonatomic, readonly, strong) NSDictionary *registrationOptions;

// Core Data support
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)deleteAllObjects:(NSString *)entityDescription;
- (NSURL *)applicationDocumentsDirectory;

// Etc.
- (UIViewController *)topViewController;

@end

