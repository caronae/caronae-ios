#import "CaronaeJoinRequestCell.h"

@implementation CaronaeJoinRequestCell

- (void)configureCellWithRequest:(NSDictionary *)request {
    _request = request;
    _userName.text = request[@"name"];
    _userCourse.text = request[@"course"];
}

- (IBAction)didTapAcceptButton:(id)sender {
    [self.delegate joinRequest:self.request hasAccepted:YES];
}

- (IBAction)didTapDeclineButton:(id)sender {
    [self.delegate joinRequest:self.request hasAccepted:NO];
}

@end
