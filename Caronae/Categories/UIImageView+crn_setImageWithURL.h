#import <UIKit/UIKit.h>

@interface UIImageView (crn_setImageWithURL)

- (void)crn_setImageWithURL:(NSURL *)url;
- (void)crn_setImageWithURL:(NSURL *)url completed:(void(^)())completionHandler;

@end
