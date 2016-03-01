#import <SDWebImage/UIImageView+WebCache.h>
#import "MenuViewController.h"
#import "ProfileViewController.h"
#import "WebViewController.h"

@interface MenuViewController ()
@property (nonatomic) NSString *photoURL;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
    
    User *user = [UserController sharedInstance].user;
    self.profileNameLabel.text = user.name;
    self.profileCourseLabel.text = user.course.length > 0 ? [NSString stringWithFormat:@"%@ | %@", user.profile, user.course] : user.profile;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    User *user = [UserController sharedInstance].user;
    NSString *userPhotoURL = user.profilePictureURL;
    if (userPhotoURL.length > 0 && ![userPhotoURL isEqualToString:self.photoURL]) {
        self.photoURL = userPhotoURL;
        [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:userPhotoURL]
                                 placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                                          options:SDWebImageRefreshCached | SDWebImageRetryFailed];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewProfile"]) {
        ProfileViewController *vc = segue.destinationViewController;
        vc.user = [UserController sharedInstance].user;
    }
    else if ([segue.identifier isEqualToString:@"About"]) {
        WebViewController *vc = segue.destinationViewController;
        vc.page = WebViewAboutPage;
    }
    else if ([segue.identifier isEqualToString:@"TermsOfUse"]) {
        WebViewController *vc = segue.destinationViewController;
        vc.page = WebViewTermsOfUsePage;
    }
    else if ([segue.identifier isEqualToString:@"FAQ"]) {
        WebViewController *vc = segue.destinationViewController;
        vc.page = WebViewFAQPage;
    }
}

- (void)openRidesHistory {
    [self performSegueWithIdentifier:@"RidesHistory" sender:nil];
}

@end
