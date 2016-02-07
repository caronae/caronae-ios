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
    _userCourse.text = [NSString stringWithFormat:@"%@ | %@",request[@"profile"], request[@"course"]];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [_acceptButton setTitleColor:color forState:UIControlStateNormal];
    _acceptButton.layer.borderColor = color.CGColor;
    _userPhoto.layer.borderColor = color.CGColor;
    self.tintColor = color;
}

- (void)setButtonsEnabled:(BOOL)enabled {
    _acceptButton.enabled = enabled;
    _declineButton.enabled = enabled;
    if (enabled) {
        _acceptButton.alpha = 1.0f;
        _declineButton.alpha = 1.0f;
    }
    else {
        _acceptButton.alpha = 0.5f;
        _declineButton.alpha = 0.5f;
    }
}


#pragma mark - IBActions

- (IBAction)didTapAcceptButton:(id)sender {
    [self.delegate joinRequest:self.request hasAccepted:YES cell:self];
}

- (IBAction)didTapDeclineButton:(id)sender {
    [self.delegate joinRequest:self.request hasAccepted:NO cell:self];
}

- (IBAction)didTapUserDetails:(id)sender {
    [self.delegate tappedUserDetailsForRequest:self.request];
}

@end
