#import <UIKit/UIKit.h>

@class CaronaeJoinRequestCell;

@protocol JoinRequestDelegate <NSObject>

- (void)joinRequest:(NSDictionary *)request hasAccepted:(BOOL)accepted cell:(CaronaeJoinRequestCell *)cell;
- (void)tappedUserDetailsForRequest:(NSDictionary *)request ;

@end

@interface CaronaeJoinRequestCell : UITableViewCell

- (void)configureCellWithRequest:(NSDictionary *)request;
- (void)setButtonsEnabled:(BOOL)active;

@property (nonatomic, assign) id<JoinRequestDelegate> delegate;
@property (nonatomic) NSDictionary *request;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userCourse;
@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (nonatomic) UIColor *color;

@end
