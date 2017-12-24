#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+crn_setImageWithURL.h"
#import "Caronae-Swift.h"

@class Constants;

@implementation UIImageView (crn_setImageWithURL)

- (void)crn_setImageWithURL:(NSURL *)url {
    [self crn_setImageWithURL:url completed:nil];
}

- (void)crn_setImageWithURL:(NSURL *)url completed:(void(^)())completionHandler {
    [self sd_setImageWithURL:url
            placeholderImage:[UIImage imageNamed:[Constants CaronaePlaceholderProfileImageObjc]]
                     options:SDWebImageRetryFailed
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                       if (cacheType == SDImageCacheTypeNone) {
                           self.alpha = 0.5;
                           [UIView animateWithDuration:0.3 animations:^{
                               self.alpha = 1;
                           }];
                       } else {
                           self.alpha = 1;
                       }
                       
                       if (completionHandler) {
                           completionHandler();
                       }
                   }];
}

@end
