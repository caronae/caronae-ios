#import <SDWebImage/UIImageView+WebCache.h>
#import "MenuViewController.h"
#import "ProfileViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
    
    NSDictionary *user = [CaronaeDefaults defaults].user;
    self.profileNameLabel.text = user[@"name"];
    self.profileCourseLabel.text = user[@"course"];
    if (user[@"profile_pic_url"] && [user[@"profile_pic_url"] isKindOfClass:[NSString class]] && ![user[@"profile_pic_url"] isEqualToString:@""]) {
        [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:user[@"profile_pic_url"]]
                             placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                                      options:SDWebImageRefreshCached];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewProfile"]) {
        ProfileViewController *vc = segue.destinationViewController;
        vc.user = [CaronaeDefaults defaults].user;
    }
}

@end
