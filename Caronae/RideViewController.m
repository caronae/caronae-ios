#import <AFNetworking/AFNetworking.h>
#import "RideViewController.h"
#import "Ride.h"

@interface RideViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *driverPhoto;
@property (weak, nonatomic) IBOutlet UILabel *slotsLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverCourseLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsInCommonLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UIButton *requestRideButton;

@end

@implementation RideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Carona";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm | dd/MM";
    
    NSString *rideTitle = [NSString stringWithFormat:@"%@ → %@", _ride.neighborhood, _ride.hub];
    _titleLabel.text = [rideTitle uppercaseString];
    _dateLabel.text = [NSString stringWithFormat:@"Chegando às %@", [dateFormatter stringFromDate:_ride.date]];
    _slotsLabel.text = [NSString stringWithFormat:@"%d %@", _ride.slots, _ride.slots == 1 ? @"vaga" : @"vagas"];
    _driverNameLabel.text = _ride.driverName;
    _driverCourseLabel.text = _ride.driverCourse;
    _friendsInCommonLabel.text = [NSString stringWithFormat:@"Amigos em comum: %d", 0];
    _driverMessageLabel.text = _ride.notes;
    _routeLabel.text = _ride.route;
}

- (IBAction)didTapRequestRide:(UIButton *)sender {
    NSLog(@"Requesting to join ride %ld", _ride.rideID);
    NSDictionary *params = @{@"rideId": @(_ride.rideID)};
    
    NSString *userToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:userToken forHTTPHeaderField:@"token"];
    
    _requestRideButton.enabled = NO;
    
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/requestJoin"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Done requesting ride.");
        [_requestRideButton setTitle:@"CARONA SOLICITADA" forState:UIControlStateNormal];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
        _requestRideButton.enabled = YES;
    }];
}

@end
