#import "CaronaeJoinRequestCell.h"

@implementation CaronaeJoinRequestCell

- (void)awakeFromNib {
    UITapGestureRecognizer *pictureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapUserDetails:)];
    pictureTap.numberOfTapsRequired = 1;
    [_userPhoto addGestureRecognizer:pictureTap];
    
    UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapUserDetails:)];
    nameTap.numberOfTapsRequired = 1;
    [_userName addGestureRecognizer:nameTap];
}

- (void)configureCellWithRequest:(NSDictionary *)request {
    _request = request;
    _userName.text = request[@"name"];
    _userCourse.text = request[@"course"];
}


#pragma mark - IBActions

- (IBAction)didTapAcceptButton:(id)sender {
    [self.delegate joinRequest:self.request hasAccepted:YES];
}

- (IBAction)didTapDeclineButton:(id)sender {
    [self.delegate joinRequest:self.request hasAccepted:NO];
}

- (IBAction)didTapUserDetails:(id)sender {
    [self.delegate tappedUserDetailsForRequest:self.request];
}

@end
