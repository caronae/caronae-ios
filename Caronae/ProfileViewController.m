#import "ProfileViewController.h"
#import "CaronaeAlertController.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIButton *signoutButton;
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

- (BOOL)isMyProfile {
    return _user == [CaronaeDefaults defaults].user;
}

- (void)updateProfileFields {
    if ([self isMyProfile]) {
        self.title = @"Meu Perfil";
        _carPlateLabel.text = _user[@"car_plate"];
        _carModelLabel.text = _user[@"car_model"];
        _carColorLabel.text = _user[@"car_color"];
    }
    else {
        self.title = _user[@"name"];
        [_carDetailsView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        [_signoutButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];

        self.navigationItem.rightBarButtonItem = nil;
    }
    
    NSDateFormatter *joinedDateParser = [[NSDateFormatter alloc] init];
    joinedDateParser.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *joinedDate = [joinedDateParser dateFromString:_user[@"created_at"]];
    _joinedDateFormatter = [[NSDateFormatter alloc] init];
    _joinedDateFormatter.dateFormat = @"MM/yyyy";
    
    _nameLabel.text = _user[@"name"];
    _courseLabel.text = _user[@"course"];
    
    _joinedDateLabel.text = [self.joinedDateFormatter stringFromDate:joinedDate];
}


#pragma mark - IBActions

- (IBAction)didTapLogoutButton:(id)sender {
    CaronaeAlertController *alert = [CaronaeAlertController alertControllerWithTitle:@"Você deseja mesmo sair da sua conta?"
                                                                             message:@"Para entrar novamente você precisará do token de autorização gerado pelo SIGA."
                                                                      preferredStyle:SDCAlertControllerStyleAlert];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancelar" style:SDCAlertActionStyleCancel handler:nil]];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Sair" style:SDCAlertActionStyleDestructive handler:^(SDCAlertAction *action){
        [CaronaeDefaults defaults].user = nil;
        [self performSegueWithIdentifier:@"AuthScreen" sender:self];
    }]];
    [alert presentWithCompletion:nil];
}


@end
