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
