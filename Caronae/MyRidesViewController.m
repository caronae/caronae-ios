#import "MyRidesViewController.h"

@interface MyRidesViewController ()

@end

@implementation MyRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo"]];
}

@end
