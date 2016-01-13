#import <UIKit/UIKit.h>

@protocol JoinRequestDelegate <NSObject>

- (void)joinRequest:(NSDictionary *)request hasAccepted:(BOOL)accepted;
- (void)tappedUserDetailsForRequest:(NSDictionary *)request ;

@end

@interface CaronaeJoinRequestCell : UITableViewCell

- (void)configureCellWithRequest:(NSDictionary *)request;

@property (nonatomic, assign) id<JoinRequestDelegate> delegate;
@property (nonatomic) NSDictionary *request;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userCourse;
@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (nonatomic) UIColor *color;

@end
