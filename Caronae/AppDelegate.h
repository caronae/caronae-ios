@import UIKit;
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Notification support
- (void)setActiveScreenAccordingToNotification:(NSDictionary *)userInfo;
@property (nonatomic) AVAudioPlayer *soundPlayer;

@end

