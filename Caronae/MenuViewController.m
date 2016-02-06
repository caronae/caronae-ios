#import <SDWebImage/UIImageView+WebCache.h>
#import "MenuViewController.h"
#import "ProfileViewController.h"

@interface MenuViewController ()
@property (nonatomic) NSString *photoURL;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
    
    NSDictionary *user = [CaronaeDefaults defaults].user;
    self.profileNameLabel.text = user[@"name"];
    self.profileCourseLabel.text = user[@"course"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDictionary *user = [CaronaeDefaults defaults].user;
    id userPhotoURL = user[@"profile_pic_url"];
    if (userPhotoURL && [userPhotoURL isKindOfClass:[NSString class]] && ![userPhotoURL isEqualToString:@""] && ![userPhotoURL isEqualToString:self.photoURL]) {
        self.photoURL = userPhotoURL;
        [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:userPhotoURL]
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
