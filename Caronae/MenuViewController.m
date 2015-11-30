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
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewProfile"]) {
        ProfileViewController *vc = segue.destinationViewController;
        vc.user = [CaronaeDefaults defaults].user;
    }
}

@end
