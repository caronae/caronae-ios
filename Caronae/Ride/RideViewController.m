@import SVProgressHUD;
#import "CaronaeAlertController.h"
#import "JoinRequestCell.h"
#import "ProfileViewController.h"
#import "RideViewController.h"
#import "RiderCell.h"
#import "SHSPhoneNumberFormatter+UserConfig.h"
#import "UIImageView+crn_setImageWithURL.h"
#import "Caronae-Swift.h"

@interface RideViewController ()
<
    JoinRequestDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UIGestureRecognizerDelegate
>

@property (nonatomic) NSArray<User *> *requesters;
@property (nonatomic) NSArray<User *> *mutualFriends;
@property (nonatomic) User *selectedUser;
@property (nonatomic) UIColor *color;

@end

@implementation RideViewController

static NSString *CaronaeRequestButtonStateNew              = @"PEGAR CARONA";
static NSString *CaronaeRequestButtonStateAlreadyRequested = @"    SOLICITAÇÃO ENVIADA    ";
static NSString *CaronaeRequestButtonStateFullRide         = @"       CARONA CHEIA       ";
static NSString *CaronaeFinishButtonStateAlreadyFinished   = @"  Carona concluída";

+ (instancetype)rideViewControllerForRide:(Ride *)ride {
    RideViewController *rideVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RideViewController"];
    rideVC.ride = ride;
    return rideVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load ride from realm database if available
    [self loadRealmRide];
    
    self.title = @"Carona";
    
    [self clearNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatButtonBadge) name:CaronaeDidUpdateNotifications object:nil];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm | E | dd/MM";
    NSString *dateString = [[dateFormatter stringFromDate:_ride.date] capitalizedAfter:@"|"];
    
    _titleLabel.text = [_ride.title uppercaseString];
    if (_ride.going) {
        _dateLabel.text = [NSString stringWithFormat:@"Chegando às %@", dateString];
    } else {
        _dateLabel.text = [NSString stringWithFormat:@"Saindo às %@", dateString];
    }
    
    if ([_ride.place isKindOfClass:[NSString class]] && [_ride.place isEqualToString:@""]) {
        _referenceLabel.text = @"---";
    } else {
        _referenceLabel.text = _ride.place;
    }

    _driverNameLabel.text = _ride.driver.name;
    _driverCourseLabel.text = _ride.driver.course.length > 0 ? [NSString stringWithFormat:@"%@ | %@", _ride.driver.profile, _ride.driver.course] : _ride.driver.profile;
    
    if ([_ride.route isKindOfClass:[NSString class]] && [_ride.route isEqualToString:@""]) {
        _routeLabel.text = @"---";
    } else {
        _routeLabel.text = [[_ride.route stringByReplacingOccurrencesOfString:@", " withString:@"\n"] stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
    }
    
    if ([_ride.notes isKindOfClass:NSString.class] && [_ride.notes isEqualToString:@""]) {
        _driverMessageLabel.text = @"---";
    } else {
        _driverMessageLabel.text = _ride.notes;
    }
    
    if (_ride.driver.profilePictureURL.length > 0) {
        [_driverPhoto crn_setImageWithURL:[NSURL URLWithString:_ride.driver.profilePictureURL]];
    }
    
    self.color = [[PlaceService instance] colorForZone:_ride.region];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass(JoinRequestCell.class) bundle:nil];
    [self.requestsTable registerNib:cellNib forCellReuseIdentifier:@"Request Cell"];
    self.requestsTable.dataSource = self;
    self.requestsTable.delegate = self;
    self.requestsTable.rowHeight = 95.0f;
    self.requestsTableHeight.constant = 0;
    
    if (![_ride.date isInTheFuture]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.shareRideView removeFromSuperview];
        });
    }
    
    // If the user is the driver of the ride, load pending join requests and hide 'join' button
    if ([self userIsDriver]) {
        [self loadJoinRequests];
        [self updateChatButtonBadge];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.requestRideButton removeFromSuperview];
            [self.mutualFriendsView removeFromSuperview];
            [self.phoneView removeFromSuperview];
            
            if (!_ride.isActive || [_ride.date isInTheFuture]) {
                [self.finishRideView removeFromSuperview];
            }
        });
        
        // Car details
        User *user = UserService.instance.user;
        _carPlateLabel.text = user.carPlate.uppercaseString;
        _carModelLabel.text = user.carModel;
        _carColorLabel.text = user.carColor;
        
        // If the riders aren't provided then hide the riders view
        if (!self.riders) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.ridersView removeFromSuperview];
            });
        }
    }
    // If the user is already a rider, hide 'join' button
    else if ([self userIsRider]) {
        [self updateChatButtonBadge];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.requestRideButton removeFromSuperview];
            [self.finishRideView removeFromSuperview];
        });
        
        [self.cancelButton setTitle:@"DESISTIR" forState:UIControlStateNormal];
        SHSPhoneNumberFormatter *phoneFormatter = [[SHSPhoneNumberFormatter alloc] init];
        [phoneFormatter setDefaultOutputPattern:Caronae8PhoneNumberPattern];
        [phoneFormatter addOutputPattern:Caronae9PhoneNumberPattern forRegExp:@"[0-9]{12}\\d*$"];
        NSDictionary *result = [phoneFormatter valuesForString:_ride.driver.phoneNumber];
        NSString *formattedPhoneNumber = result[@"text"];
        [_phoneButton setTitle:formattedPhoneNumber forState:UIControlStateNormal];
        
        // Car details
        _carPlateLabel.text = _ride.driver.carPlate.uppercaseString;
        _carModelLabel.text = _ride.driver.carModel;
        _carColorLabel.text = _ride.driver.carColor;
        
        [self updateMutualFriends];
    }
    // If the user is not related to the ride, hide 'cancel' button, car details view, riders view
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cancelButton removeFromSuperview];
            [self.phoneView removeFromSuperview];
            [self.carDetailsView removeFromSuperview];
            [self.finishRideView removeFromSuperview];
            [self.ridersView removeFromSuperview];
        });
        
        // Hide driver's phone number
        _ride.driver.phoneNumber = nil;
        
        // Update the state of the join request button if the user has already requested to join
        if ([RideService.instance hasRequestedToJoinRideWithID:_ride.id]) {
            _requestRideButton.enabled = NO;
            [_requestRideButton setTitle:CaronaeRequestButtonStateAlreadyRequested forState:UIControlStateNormal];
        } else if (_rideIsFull) {
            _requestRideButton.enabled = NO;
            [_requestRideButton setTitle:CaronaeRequestButtonStateFullRide forState:UIControlStateNormal];
            _rideIsFull = NO;
        } else {
            _requestRideButton.enabled = YES;
            [_requestRideButton setTitle:CaronaeRequestButtonStateNew forState:UIControlStateNormal];
        }
        
        [self updateMutualFriends];
    }
    
    // Add gesture recognizer to phoneButton for longpress
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressPhoneButton)];
    [_phoneButton addGestureRecognizer:longPressGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.shouldOpenChatWindow) {
        [self openChatWindow];
        self.shouldOpenChatWindow = NO;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    _shareRideButton.layer.borderColor = color.CGColor;
    _shareRideButton.tintColor = color;
    _requestRideButton.backgroundColor = color;
    [_finishRideButton setTitleColor:color forState:UIControlStateNormal];
    [_shareRideButton setTitleColor:color forState:UIControlStateNormal];
}

- (void)updateMutualFriends {
    [UserService.instance mutualFriendsForUserWithFacebookID:_ride.driver.facebookID success:^(NSArray<User *> * _Nonnull mutualFriends, NSInteger totalCount) {
        if (mutualFriends.count > 0) {
            _mutualFriends = mutualFriends;
            _mutualFriendsCollectionHeight.constant = 40.0f;
            [_mutualFriendsView layoutIfNeeded];
            [_mutualFriendsCollectionView reloadData];
        }
        
        if (totalCount > 0) {
            _mutualFriendsLabel.text = [NSString stringWithFormat:@"Amigos em comum: %ld no total e %ld no Caronaê", (long)totalCount, (long)mutualFriends.count];
        } else {
            _mutualFriendsLabel.text = @"Amigos em comum: 0";
        }
    } error:^(NSError * _Nonnull error) {
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
    ChatViewController *chatVC = [[ChatViewController alloc] initWithRide:_ride color:_color];
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - IBActions

-(void)didLongPressPhoneButton {
    UIAlertController *alert = [[PhoneNumberAlert alloc] actionSheetWithView:self buttonText:_phoneButton.titleLabel.text user:_ride.driver];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)didTapPhoneButton:(id)sender {
    NSString *phoneNumber = _ride.driver.phoneNumber;
    NSString *phoneNumberURLString = [NSString stringWithFormat:@"telprompt://%@", phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumberURLString]];
}

- (IBAction)didTapRequestRide:(UIButton *)sender {
    CaronaeAlertController *alert = [CaronaeAlertController alertControllerWithTitle:@"Deseja mesmo solicitar a carona?"
                                                                             message:@"Ao confirmar, o motorista receberá uma notificação e poderá aceitar ou recusar a carona."
                                                                      preferredStyle:SDCAlertControllerStyleAlert];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancelar" style:SDCAlertActionStyleCancel handler:nil]];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Solicitar" style:SDCAlertActionStyleRecommended handler:^(SDCAlertAction *action){
        [self requestJoinRide];
    }]];
    [alert presentWithCompletion:nil];
}

- (IBAction)viewUserProfile:(id)sender {
    self.selectedUser = _ride.driver;
    [self performSegueWithIdentifier:@"ViewProfile" sender:self];
}

- (IBAction)didTapCancelRide:(id)sender {
    CaronaeAlertController *alert = [CaronaeAlertController alertControllerWithTitle:@"Deseja mesmo desistir da carona?"
                                                                             message:@"Você é livre para cancelar caronas caso não possa participar, mas é importante fazer isso com responsabilidade. Caso haja outros usuários na carona, eles serão notificados."
                                                                      preferredStyle:SDCAlertControllerStyleAlert];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Voltar" style:SDCAlertActionStyleCancel handler:nil]];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Desistir" style:SDCAlertActionStyleDestructive handler:^(SDCAlertAction *action){
        [self cancelRide];
    }]];
    [alert presentWithCompletion:nil];
}

- (IBAction)didTapFinishRide:(id)sender {
    CaronaeAlertController *alert = [CaronaeAlertController alertControllerWithTitle:@"E aí? Correu tudo bem?"
                                                                             message:@"Caso você tenha tido algum problema com a carona, use o Falaê para entrar em contato conosco."
                                                                      preferredStyle:SDCAlertControllerStyleAlert];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancelar" style:SDCAlertActionStyleCancel handler:nil]];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Concluir" style:SDCAlertActionStyleRecommended handler:^(SDCAlertAction *action){
        [self finishRide];
    }]];
    [alert presentWithCompletion:nil];
}

- (IBAction)didTapShareRide:(id)sender {
    NSString *rideTitle = [NSString stringWithFormat:@"Carona: %@", _ride.title];
    NSURL *rideLink = [NSURL URLWithString:[NSString stringWithFormat:@"https://caronae.com.br/carona/%ld", (long)_ride.id]];
    NSArray *rideToShare = @[rideTitle, _dateLabel.text, rideLink];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:rideToShare applicationActivities:nil];
    NSArray *excludeActivities = @[UIActivityTypeAddToReadingList];
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}


#pragma mark - Ride operations

- (void)cancelRide {
    if ([self userIsDriver] && _ride.isRoutine) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Esta carona pertence a uma rotina."
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Desistir somente desta" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            [self leaveRide];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Desistir da rotina" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            [self deleteRoutine];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self leaveRide];
    }
}

- (void)leaveRide {
    NSLog(@"Requesting to leave/cancel ride %ld", (long)_ride.id);
    
    _cancelButton.enabled = NO;
    [SVProgressHUD show];
    
    [RideService.instance leaveRideWithID:_ride.id success:^{
        [SVProgressHUD dismiss];
        NSLog(@"User left the ride.");
        
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(NSError * _Nonnull error) {
        NSLog(@"Error leaving/cancelling ride: %@", error.localizedDescription);
        [SVProgressHUD dismiss];
        _cancelButton.enabled = YES;
        [CaronaeAlertController presentOkAlertWithTitle:@"Algo deu errado." message:[NSString stringWithFormat:@"Não foi possível cancelar sua carona. (%@)", error.localizedDescription]];
    }];
}

- (void)finishRide {
    NSLog(@"Requesting to finish ride %ld", (long)_ride.id);
    
    _finishRideButton.enabled = NO;
    [SVProgressHUD show];
    
    [RideService.instance finishRideWithID:_ride.id success:^{
        [SVProgressHUD dismiss];
        NSLog(@"User finished the ride.");
        
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(NSError * _Nonnull error) {
        NSLog(@"Error finishing ride: %@", error.localizedDescription);
        [SVProgressHUD dismiss];
        _finishRideButton.enabled = YES;
        [CaronaeAlertController presentOkAlertWithTitle:@"Algo deu errado." message:[NSString stringWithFormat:@"Não foi possível concluir sua carona. (%@)", error.localizedDescription]];
    }];
}


#pragma mark - Join request methods

- (void)requestJoinRide {
    NSLog(@"Requesting to join ride %ld", (long)_ride.id);
    
    _requestRideButton.enabled = NO;
    [SVProgressHUD show];
    
    [RideService.instance requestJoinOnRideWithID:_ride.id success:^{
        [SVProgressHUD dismiss];
        NSLog(@"Done requesting ride.");
        [_requestRideButton setTitle:CaronaeRequestButtonStateAlreadyRequested forState:UIControlStateNormal];
    } error:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error requesting to join ride: %@", error.localizedDescription);
        _requestRideButton.enabled = YES;
        [CaronaeAlertController presentOkAlertWithTitle:@"Algo deu errado." message:[NSString stringWithFormat:@"Não foi possível solicitar a carona. (%@)", error.localizedDescription]];
    }];

}

- (void)loadJoinRequests {
    [RideService.instance getRequestersForRideWithID:_ride.id success:^(NSArray<User *> * _Nonnull users) {
        self.requesters = users;
        if (self.requesters.count > 0) {
            [self.requestsTable reloadData];
            [self adjustHeightOfTableview];
        }        
    } error:^(NSError * _Nonnull error) {
        NSLog(@"Error loading join requests for ride %lu: %@", (long)_ride.id, error.localizedDescription);
        [CaronaeAlertController presentOkAlertWithTitle:@"Algo deu errado." message:[NSString stringWithFormat:@"Não foi possível carregar as solicitações da sua carona. (%@)", error.localizedDescription]];
    }];
}

- (void)handleAcceptedJoinRequest:(User *)requestingUser cell:(JoinRequestCell *)cell {
    [cell setButtonsEnabled:NO];
    
    if (_ride.availableSlots == 1 && _requesters.count > 1) {
        CaronaeAlertController *alert = [CaronaeAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Deseja mesmo aceitar %@?", requestingUser.firstName]
                                                                                 message:@"Ao aceitar, sua carona estará cheia e você irá recusar os outros caronistas."
                                                                          preferredStyle:SDCAlertControllerStyleAlert];
        [alert addAction:[SDCAlertAction actionWithTitle:@"Cancelar" style:SDCAlertActionStyleCancel handler:^(SDCAlertAction *action){
            [cell setButtonsEnabled:YES];
        }]];
        [alert addAction:[SDCAlertAction actionWithTitle:@"Aceitar" style:SDCAlertActionStyleRecommended handler:^(SDCAlertAction *action){
            [self answerJoinRequest:requestingUser hasAccepted:YES cell:cell];
        }]];
        [alert presentWithCompletion:nil];
    } else {
        [self answerJoinRequest:requestingUser hasAccepted:YES cell:cell];
    }
}

- (void)answerJoinRequest:(User *)requestingUser hasAccepted:(BOOL)accepted cell:(JoinRequestCell *)cell {
    [cell setButtonsEnabled:NO];
    
    [RideService.instance answerRequestOnRideWithID:_ride.id fromUser:requestingUser accepted:accepted success:^{
        NSLog(@"Request for user %@ was %@", requestingUser.name, accepted ? @"accepted" : @"not accepted");
        [self removeJoinRequest:requestingUser];
        if (accepted) {
            [_ridersCollectionView reloadData];
            [self removeAllJoinRequestIfNeeded];
        }
    } error:^(NSError * _Nonnull error) {
        NSLog(@"Error accepting join request: %@", error.localizedDescription);
        [cell setButtonsEnabled:YES];
    }];
}

- (void)removeAllJoinRequestIfNeeded {
    if (_ride.availableSlots == 0) {
        for (User *requester in _requesters) {
            [self removeJoinRequest:requester];
        }
    }
}

- (void)removeJoinRequest:(User *)requestingUser {
    NSMutableArray *joinRequestsMutable = [NSMutableArray arrayWithArray:self.requesters];
    [joinRequestsMutable removeObject:requestingUser];
    
    [self.requestsTable beginUpdates];
    unsigned long index = [self.requesters indexOfObject:requestingUser];
    [self.requestsTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.requesters = joinRequestsMutable;
    [self.requestsTable endUpdates];
    [self adjustHeightOfTableview];
    [self clearNotificationOfJoinRequestFrom:requestingUser.id];
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
    return self.requesters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JoinRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Request Cell" forIndexPath:indexPath];
    
    cell.delegate = self;
    [cell configureCellWithUser:self.requesters[indexPath.row]];
    [cell setColor:self.color];
    
    return cell;
}

- (void)adjustHeightOfTableview {
    [self.view layoutIfNeeded];
    CGFloat height = 0.0f;
    if (self.requesters.count > 0) {
        height = self.requesters.count * self.requestsTable.rowHeight;
    }
    self.requestsTableHeight.constant = height;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - Collection methods (Riders, Mutual friends)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _ridersCollectionView) {
        
        // Show message if there is no riders
        if ([self.riders count] == 0) {
            [_noRidersLabel setHidden: NO];
        } else {
            [_noRidersLabel setHidden: YES];
        }
        
        return [self.riders count];
    } else {
        return _mutualFriends.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RiderCell *cell;
    User *user;
    
    if (collectionView == _ridersCollectionView) {
        user = [self riderAtIndex:indexPath.row];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Rider Cell" forIndexPath:indexPath];
    } else {
        user = self.mutualFriends[indexPath.row];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Friend Cell" forIndexPath:indexPath];
    }
    
    [cell configureWithUser:user];    
    
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
