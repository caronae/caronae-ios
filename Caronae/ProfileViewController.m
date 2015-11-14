#import "ProfileViewController.h"

@interface ProfileViewController ()
@property (nonatomic) NSDateFormatter *joinedDateFormatter;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateProfileFields];
}

- (IBAction)didTapLogoutButton:(id)sender {
    // TODO: Add confirmation dialog
    [self performSegueWithIdentifier:@"AuthScreen" sender:self];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"user"];
}

- (void)updateProfileFields {
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    
    NSDateFormatter *joinedDateParser = [[NSDateFormatter alloc] init];
    joinedDateParser.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *joinedDate = [joinedDateParser dateFromString:user[@"created_at"]];
    self.joinedDateFormatter = [[NSDateFormatter alloc] init];
    self.joinedDateFormatter.dateFormat = @"MM/yyyy";
    
    self.nameLabel.text = user[@"name"];
    self.courseLabel.text = user[@"course"];
    
    self.joinedDateLabel.text = [self.joinedDateFormatter stringFromDate:joinedDate];
    
    self.carPlateLabel.text = user[@"car_plate"];
    self.carModelLabel.text = user[@"car_model"];
    self.carColorLabel.text = user[@"car_color"];
}

@end
