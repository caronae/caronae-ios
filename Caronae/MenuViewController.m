#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
    
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    self.profileNameLabel.text = user[@"name"];
    self.profileCourseLabel.text = user[@"course"];
}

@end
