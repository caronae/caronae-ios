#import <AFNetworking/AFNetworking.h>
#import <CoreData/CoreData.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "AppDelegate.h"
#import "CaronaeAlertController.h"
#import "Chat.h"
#import "ChatStore.h"
#import "ChatViewController.h"
#import "JoinRequestCell.h"
#import "Notification.h"
#import "ProfileViewController.h"
#import "Ride.h"
#import "RideViewController.h"
#import "RiderCell.h"

@interface RideViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, JoinRequestDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) NSArray<User *> *joinRequests;
@property (nonatomic) NSArray<User *> *mutualFriends;
@property (nonatomic) User *selectedUser;
@property (nonatomic) UIColor *color;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation RideViewController

static NSString *CaronaeRequestButtonStateNew              = @"PEGAR CARONA";
static NSString *CaronaeRequestButtonStateAlreadyRequested = @"    AGUARDANDO AUTORIZAÇÃO    ";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Carona";
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm | dd/MM";
    
    _titleLabel.text = [_ride.title uppercaseString];   
    _dateLabel.text = [NSString stringWithFormat:@"Chegando às %@", [dateFormatter stringFromDate:_ride.date]];
    
    if ([_ride.place isKindOfClass:[NSString class]] && [_ride.place isEqualToString:@""]) {
        _referenceLabel.text = @"---";
    }
    else {
        _referenceLabel.text = _ride.place;
    }

    _driverNameLabel.text = _ride.driver.name;
    _driverCourseLabel.text = [NSString stringWithFormat:@"%@ | %@", _ride.driver.profile, _ride.driver.course];
    
    if ([_ride.route isKindOfClass:[NSString class]] && [_ride.route isEqualToString:@""]) {
        _routeLabel.text = @"---";
    }
    else {
        _routeLabel.text = [[_ride.route stringByReplacingOccurrencesOfString:@", " withString:@"\n"] stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
    }
    
    if ([_ride.notes isKindOfClass:NSString.class] && [_ride.notes isEqualToString:@""]) {
        _driverMessageLabel.text = @"---";
    }
    else {
        _driverMessageLabel.text = _ride.notes;
    }
    
    if (_ride.driver.profilePictureURL && ![_ride.driver.profilePictureURL isEqualToString:@""]) {
        [_driverPhoto sd_setImageWithURL:[NSURL URLWithString:_ride.driver.profilePictureURL]
                  placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                           options:SDWebImageRefreshCached];
    }
    
    self.color = [CaronaeDefaults colorForZone:_ride.zone];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass(JoinRequestCell.class) bundle:nil];
    [self.requestsTable registerNib:cellNib forCellReuseIdentifier:@"Request Cell"];
    self.requestsTable.dataSource = self;
    self.requestsTable.delegate = self;
    self.requestsTable.rowHeight = 95.0f;
    self.requestsTableHeight.constant = 0;
    
    // If the user is the driver of the ride, load pending join requests and hide 'join' button
    if ([self userIsDriver]) {
        [self loadJoinRequests];
        [self.requestRideButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        [self.mutualFriendsView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        
        // Car details
        User *user = [CaronaeDefaults defaults].user;
        _carPlateLabel.text = user.carPlate;
        _carModelLabel.text = user.carModel;
        _carColorLabel.text = user.carColor;
    }
    // If the user is already a rider, hide 'join' button
    else if ([self userIsRider]) {
        [self.requestRideButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        [self.finishRideView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        [self.cancelButton setTitle:@"DESISTIR" forState:UIControlStateNormal];
        
        // Car details
        _carPlateLabel.text = _ride.driver.carPlate;
        _carModelLabel.text = _ride.driver.carModel;
        _carColorLabel.text = _ride.driver.carColor;
        
        [self updateMutualFriends];
    }
    // If the user is not related to the ride, hide 'cancel' button, car details view, riders view, chat button
    else {
        [self.cancelButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        [self.carDetailsView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        [self.finishRideView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        [self.ridersView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        
        self.navigationItem.rightBarButtonItem = nil;
        
        // Update the state of the join request button if the user has already requested to join
        if ([CaronaeDefaults hasUserAlreadyRequestedJoin:_ride]) {
            _requestRideButton.enabled = NO;
            [_requestRideButton setTitle:CaronaeRequestButtonStateAlreadyRequested forState:UIControlStateNormal];
        }
        else {
            _requestRideButton.enabled = YES;
            [_requestRideButton setTitle:CaronaeRequestButtonStateNew forState:UIControlStateNormal];
        }
        
        [self updateMutualFriends];
    }
    
    // If the riders aren't provided then hide the riders view
    if (!_ride.users) {
        UILabel *noRidersLabel = [[UILabel alloc] init];
        noRidersLabel.text = @"Não há caronistas aprovados.\n\n\n\n\n";
        noRidersLabel.numberOfLines = 0;
        noRidersLabel.font = [UIFont systemFontOfSize:11.0f];
        noRidersLabel.textColor = [UIColor lightGrayColor];
        [noRidersLabel sizeToFit];
        self.ridersCollectionView.backgroundView = noRidersLabel;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.shouldOpenChatWindow) {
        [self openChatWindow];
        self.shouldOpenChatWindow = NO;
    }
}

- (void)clearNotifications {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(Notification.class) inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.includesPropertyValues = NO;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == 'joinRequest' AND rideID = %@", @(self.ride.rideID)];
    fetchRequest.predicate = predicate;
    
    NSError *error;
    NSArray<Notification *> *unreadNotifications = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Whoops, couldn't load unread notifications for chat: %@", error.localizedDescription);
        return;
    }
    
    for (id notification in unreadNotifications) {
        [self.managedObjectContext deleteObject:notification];
    }
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't delete notifications for chat: %@", error.localizedDescription);
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CaronaeDidUpdateNotifications
                                                        object:nil
                                                      userInfo:@{@"msgType": @"joinRequest"}];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    _headerView.backgroundColor = color;
    _clockIcon.tintColor = color;
    _dateLabel.textColor = color;
    _driverPhoto.layer.borderColor = color.CGColor;
    _carIconPlate.tintColor = color;
    _carIconModel.tintColor = color;
    _carIconColor.tintColor = color;
    _finishRideButton.layer.borderColor = color.CGColor;
    _finishRideButton.tintColor = color;
    [_finishRideButton setTitleColor:color forState:UIControlStateNormal];
}

- (BOOL)userIsDriver {
    return [[CaronaeDefaults defaults].user.userID isEqualToNumber:_ride.driver.userID];
}

- (BOOL)userIsRider {
    for (User *user in _ride.users) {
        if ([user.userID isEqualToNumber:[CaronaeDefaults defaults].user.userID]) {
            return YES;
        }
    }
    return NO;
}

- (void)updateMutualFriends {
    // Abort if the Facebook accounts are not connected.
    if (![CaronaeDefaults userFBToken] || ![_ride.driver.facebookID isEqualToString:@""]) {
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:[CaronaeDefaults userFBToken] forHTTPHeaderField:@"Facebook-Token"];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:[NSString stringWithFormat:@"/user/%@/mutualFriends", _ride.driver.facebookID]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *mutualFriendsJSON = responseObject[@"mutual_friends"];
        NSError *error;
        NSArray<User *> *mutualFriends = [MTLJSONAdapter modelsOfClass:User.class fromJSONArray:mutualFriendsJSON error:&error];
        
        if (error) {
            NSLog(@"Error parsing mutual friends. %@", error.localizedDescription);
        }
        
        if (mutualFriends.count > 0) {
            _mutualFriends = mutualFriends;
            _mutualFriendsCollectionHeight.constant = 40.0f;
            [_mutualFriendsView layoutIfNeeded];
            [_mutualFriendsCollectionView reloadData];
        }
        _mutualFriendsLabel.text = [NSString stringWithFormat:@"Amigos em comum: %d", [responseObject[@"total_count"] intValue]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error loading mutual friends for user: %@", error.localizedDescription);
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewProfile"]) {
        ProfileViewController *vc = segue.destinationViewController;
        vc.user = self.selectedUser;
    }
}

- (void)openChatWindow {
    Chat *chat = [ChatStore chatForRide:_ride];
    if (chat) {
        ChatViewController *chatVC = [[ChatViewController alloc] initWithChat:chat andColor:_color];
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

#pragma mark - IBActions

- (IBAction)didTapRequestRide:(UIButton *)sender {
    [self requestJoinRide];
}

- (IBAction)viewUserProfile:(id)sender {
    self.selectedUser = _ride.driver;
    [self performSegueWithIdentifier:@"ViewProfile" sender:self];
}

- (IBAction)didTapCancelRide:(id)sender {
    CaronaeAlertController *alert = [CaronaeAlertController alertControllerWithTitle:@"Deseja mesmo desistir da carona?"
                                                                             message:@"Você é livre para cancelar caronas caso não possa participar, mas é importante fazer isso com responsabilidade. Caso haja outros usuários na carona, eles serão notificados."
                                                                      preferredStyle:SDCAlertControllerStyleAlert];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancelar" style:SDCAlertActionStyleCancel handler:nil]];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Desistir" style:SDCAlertActionStyleDestructive handler:^(SDCAlertAction *action){
        [self cancelRide];
    }]];
    [alert presentWithCompletion:nil];
}

- (IBAction)didTapFinishRide:(id)sender {
    CaronaeAlertController *alert = [CaronaeAlertController alertControllerWithTitle:@"Concluir carona"
                                                                             message:@"E aí? Correu tudo bem? Deseja mesmo concluir a carona?"
                                                                      preferredStyle:SDCAlertControllerStyleAlert];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancelar" style:SDCAlertActionStyleCancel handler:nil]];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Concluir" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action){
        [self finishRide];
    }]];
    [alert presentWithCompletion:nil];
}

- (IBAction)didTapChatButton:(id)sender {
    [self openChatWindow];
}


#pragma mark - Ride operations

- (void)cancelRide {
    NSLog(@"Requesting to leave/cancel ride %ld", _ride.rideID);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    NSDictionary *params = @{@"rideId": @(_ride.rideID)};
    
    _cancelButton.enabled = NO;
    [SVProgressHUD show];
    
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/leaveRide"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"User left the ride. (Message: %@)", responseObject[@"message"]);
        
        [[ChatStore chatForRide:_ride] unsubscribe];
        
        if (_delegate && [_delegate respondsToSelector:@selector(didDeleteRide:)]) {
            [_delegate didDeleteRide:_ride];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error leaving/cancelling ride: %@", error.localizedDescription);
        [SVProgressHUD dismiss];
        _cancelButton.enabled = YES;
    }];
}

- (void)finishRide {
    NSLog(@"Requesting to finish ride %ld", _ride.rideID);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    NSDictionary *params = @{@"rideId": @(_ride.rideID)};
    
    _finishRideButton.enabled = NO;
    [SVProgressHUD show];
    
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/finishRide"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {        [SVProgressHUD dismiss];
        NSLog(@"User finished the ride. (Message: %@)", responseObject[@"message"]);
        
        [[ChatStore chatForRide:_ride] unsubscribe];
        self.navigationItem.rightBarButtonItem = nil;
        
        [_finishRideButton setTitle:@"  Carona concluída" forState:UIControlStateNormal];
        [self.cancelButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error finishing ride: %@", error.localizedDescription);
        [SVProgressHUD dismiss];
        _finishRideButton.enabled = YES;
    }];
}


#pragma mark - Join request methods

- (void)requestJoinRide {
    NSLog(@"Requesting to join ride %ld", _ride.rideID);
    NSDictionary *params = @{@"rideId": @(_ride.rideID)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    _requestRideButton.enabled = NO;
    [SVProgressHUD show];
    
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/requestJoin"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"Done requesting ride. (Message: %@)", responseObject[@"message"]);
        [CaronaeDefaults addToCachedJoinRequests:_ride];
        [_requestRideButton setTitle:CaronaeRequestButtonStateAlreadyRequested forState:UIControlStateNormal];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error requesting to join ride: %@", error.localizedDescription);
        _requestRideButton.enabled = YES;
    }];
}

- (void)loadJoinRequests {
    long rideID = _ride.rideID;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:[NSString stringWithFormat:@"/ride/getRequesters/%ld", rideID]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error;
        NSArray<User *> *joinRequests = [MTLJSONAdapter modelsOfClass:User.class fromJSONArray:responseObject error:&error];
        
        if (!error) {
            self.joinRequests = joinRequests;
            if (joinRequests.count > 0) {
                [self.requestsTable reloadData];
                [self adjustHeightOfTableview];
            }
            
            [self clearNotifications];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error loading join requests for ride %lu: %@", rideID, error.localizedDescription);
    }];
    
}

- (void)joinRequest:(User *)requestingUser hasAccepted:(BOOL)accepted cell:(JoinRequestCell *)cell {
    NSLog(@"Request for user %@ was %@", requestingUser.name, accepted ? @"accepted" : @"not accepted");
    NSDictionary *params = @{@"userId": requestingUser.userID,
                             @"rideId": @(_ride.rideID),
                             @"accepted": @(accepted)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [cell setButtonsEnabled:NO];
    
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/answerJoinRequest"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Answer to join request successfully sent.");
        [self removeJoinRequest:requestingUser];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error accepting join request: %@", error.localizedDescription);
        [cell setButtonsEnabled:YES];
    }];
}

- (void)removeJoinRequest:(User *)requestingUser {
    NSMutableArray *joinRequestsMutable = [NSMutableArray arrayWithArray:self.joinRequests];
    [joinRequestsMutable removeObject:requestingUser];
    
    [self.requestsTable beginUpdates];
    unsigned long index = [self.joinRequests indexOfObject:requestingUser];
    [self.requestsTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.joinRequests = joinRequestsMutable;
    [self.requestsTable endUpdates];
    [self adjustHeightOfTableview];
}

- (void)tappedUserDetailsForRequest:(User *)user {
    self.selectedUser = user;
    [self performSegueWithIdentifier:@"ViewProfile" sender:self];
}


#pragma mark - Table methods (Join requests)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.joinRequests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JoinRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Request Cell" forIndexPath:indexPath];
    
    cell.delegate = self;
    [cell configureCellWithUser:self.joinRequests[indexPath.row]];
    [cell setColor:self.color];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 300, 20)];
    label.font = [UIFont boldSystemFontOfSize:13.0f];
    label.text = @"PEDIDOS DE CARONA";
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:label];
    
    return headerView;
}

- (void)adjustHeightOfTableview {
    [self.view layoutIfNeeded];
    CGFloat height = self.joinRequests.count > 0 ? self.requestsTable.contentSize.height : 0;
    self.requestsTableHeight.constant = height;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - Collection methods (Riders)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _ridersCollectionView) {
        return _ride.users.count;
    }
    else {
        return _mutualFriends.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RiderCell *cell;
    User *user;
    
    if (collectionView == _ridersCollectionView) {
        user = _ride.users[indexPath.row];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Rider Cell" forIndexPath:indexPath];
    }
    else {
        user = _mutualFriends[indexPath.row];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Friend Cell" forIndexPath:indexPath];
        
    }
    
    cell.user = user;
    cell.nameLabel.text = user.firstName;
    
    if (user.profilePictureURL && ![user.profilePictureURL isEqualToString:@""]) {
        [cell.photo sd_setImageWithURL:[NSURL URLWithString:user.profilePictureURL]
                      placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                               options:SDWebImageRefreshCached];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (collectionView == _ridersCollectionView) {
        RiderCell *cell = (RiderCell *)[collectionView cellForItemAtIndexPath:indexPath];
        self.selectedUser = cell.user;
        
        [self performSegueWithIdentifier:@"ViewProfile" sender:self];
    }
}

@end
