@import UIKit;

@class User;

@class JoinRequestCell;

@protocol JoinRequestDelegate <NSObject>

- (void)handleAcceptedJoinRequest:(User *)requestingUser cell:(JoinRequestCell *)cell;
- (void)answerJoinRequest:(User *)requestingUser hasAccepted:(BOOL)accepted cell:(JoinRequestCell *)cell;
- (void)tappedUserDetailsForRequest:(User *)user;

@end

@interface JoinRequestCell : UITableViewCell

- (void)configureCellWithUser:(User *)user;
- (void)setButtonsEnabled:(BOOL)active;
- (void)setColor:(UIColor *)color;

@property (nonatomic, assign) id<JoinRequestDelegate> delegate;
@property (nonatomic) User *requestingUser;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userCourse;
@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (nonatomic) UIColor *color;

@end
