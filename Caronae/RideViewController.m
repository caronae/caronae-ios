#import <AFNetworking/AFNetworking.h>
#import "RideViewController.h"
#import "CaronaeJoinRequestCell.h"
#import "ProfileViewController.h"
#import "Ride.h"

@interface RideViewController () <UITableViewDelegate, UITableViewDataSource, JoinRequestDelegate, UIGestureRecognizerDelegate>
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
@property (weak, nonatomic) IBOutlet UITableView *requestsTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *requestsTableHeight;
@property (nonatomic) NSArray *joinRequests;
@property (nonatomic) NSDictionary *selectedUser;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
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
    
    UINib *cellNib = [UINib nibWithNibName:@"CaronaeJoinRequestCell" bundle:nil];
    [self.requestsTable registerNib:cellNib forCellReuseIdentifier:@"Request Cell"];
    self.requestsTable.dataSource = self;
    self.requestsTable.delegate = self;
    self.requestsTable.rowHeight = 95.0f;
    self.requestsTableHeight.constant = 0;
    
    // If the user is the driver of the ride, load pending join requests and hide 'join' button
    if ([self userIsDriver]) {
        [self searchForJoinRequests];
        [self.requestRideButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    }
    else {
        [self.cancelButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];        
    }
}

- (BOOL)userIsDriver {
    return [[CaronaeDefaults defaults].user[@"id"] isEqual:_ride.driverID];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewProfile"]) {
        ProfileViewController *vc = segue.destinationViewController;
        vc.user = self.selectedUser;
    }
}


#pragma mark - IBActions

- (IBAction)didTapRequestRide:(UIButton *)sender {
    NSLog(@"Requesting to join ride %ld", _ride.rideID);
    NSDictionary *params = @{@"rideId": @(_ride.rideID)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    _requestRideButton.enabled = NO;
    
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/requestJoin"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Done requesting ride.");
        [_requestRideButton setTitle:@"CARONA SOLICITADA" forState:UIControlStateNormal];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
        _requestRideButton.enabled = YES;
    }];
}

- (IBAction)viewUserProfile:(id)sender {
    self.selectedUser = @{@"name": _ride.driverName, @"course": _ride.driverCourse, @"id": _ride.driverID};
    [self performSegueWithIdentifier:@"ViewProfile" sender:self];
}

- (IBAction)didTapCancelRide:(id)sender {
    // TODO: Add confirmation dialog
    NSLog(@"Requesting to cancel ride %ld", _ride.rideID);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    _cancelButton.enabled = NO;
    
    [manager DELETE:[CaronaeAPIBaseURL stringByAppendingString:[NSString stringWithFormat:@"/ride/%ld", _ride.rideID]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Ride was deleted.");
        
        if ([_delegate respondsToSelector:@selector(didDeleteRide:)]) {
            [_delegate didDeleteRide:_ride];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
        _cancelButton.enabled = YES;
    }];
}

#pragma mark - Join request methods

- (void)searchForJoinRequests {
    long rideID = _ride.rideID;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    //    [self showLoadingHUD:YES];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:[NSString stringWithFormat:@"/ride/getRequesters/%ld", rideID]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        [self showLoadingHUD:NO];
        
        NSLog(@"Results for join requests are back.");
        
        NSError *responseError;
        NSArray *joinRequests = [RideViewController parseJoinRequestsFromResponse:responseObject withError:&responseError];
        if (!responseError) {
            NSLog(@"Search returned %lu join requests.", (unsigned long)joinRequests.count);
            self.joinRequests = joinRequests;
            if (joinRequests.count > 0) {
                [self.requestsTable reloadData];
                [self adjustHeightOfTableview];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [self showLoadingHUD:NO];
        NSLog(@"Error: %@", error.description);
    }];
    
}

+ (NSArray *)parseJoinRequestsFromResponse:(id)responseObject withError:(NSError *__autoreleasing *)err {
    // Check if we received an array of the rides
    if ([responseObject isKindOfClass:NSArray.class]) {
        return responseObject;
    }
    else {
        if (err) {
            NSDictionary *errorInfo = @{
                                        NSLocalizedDescriptionKey: NSLocalizedString(@"Unexpected server response.", nil)
                                        };
            *err = [NSError errorWithDomain:CaronaeErrorDomain code:CaronaeErrorInvalidResponse userInfo:errorInfo];
        }
    }
    
    return nil;
}

- (void)joinRequest:(NSDictionary *)request hasAccepted:(BOOL)accepted {
    NSLog(@"Request for user %@ was %@", request[@"name"], accepted ? @"accepted" : @"not accepted");
    NSDictionary *params = @{@"userId": request[@"id"],
                             @"rideId": @(_ride.rideID),
                             @"accepted": @(accepted)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/answerJoinRequest"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Answer to join request successfully sent.");
        [self removeJoinRequest:request];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
    }];
}

- (void)removeJoinRequest:(NSDictionary *)request {
    NSMutableArray *joinRequestsMutable = [NSMutableArray arrayWithArray:self.joinRequests];
    [joinRequestsMutable removeObject:request];
    
    [self.requestsTable beginUpdates];
    unsigned long index = [self.joinRequests indexOfObject:request];
    [self.requestsTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.joinRequests = joinRequestsMutable;
    [self.requestsTable endUpdates];
    [self adjustHeightOfTableview];
}

- (void)tappedUserDetailsForRequest:(NSDictionary *)request {
    self.selectedUser = request;
    [self performSegueWithIdentifier:@"ViewProfile" sender:self];
}


#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.joinRequests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CaronaeJoinRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Request Cell" forIndexPath:indexPath];
    
    cell.delegate = self;
    [cell configureCellWithRequest:self.joinRequests[indexPath.row]];
    
    return cell;
}

- (void)adjustHeightOfTableview {
    [self.view layoutIfNeeded];
    CGFloat height = self.requestsTable.contentSize.height;
    self.requestsTableHeight.constant = height;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
