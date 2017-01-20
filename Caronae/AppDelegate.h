@import UIKit;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Notification support
- (void)setActiveScreenAccordingToNotification:(NSDictionary *)userInfo;

@end

