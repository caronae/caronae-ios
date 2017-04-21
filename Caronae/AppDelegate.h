@import UIKit;
#import <AudioToolbox/AudioServices.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Notification support
- (void)setActiveScreenAccordingToNotification:(NSDictionary *)userInfo;
@property (nonatomic) SystemSoundID beepSound;

@end

