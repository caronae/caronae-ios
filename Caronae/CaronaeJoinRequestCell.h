#import <UIKit/UIKit.h>

@protocol JoinRequestDelegate <NSObject>

- (void)joinRequest:(NSDictionary *)request hasAccepted:(BOOL)accepted;

@end

@interface CaronaeJoinRequestCell : UITableViewCell

- (void)configureCellWithRequest:(NSDictionary *)request;

@property (nonatomic, assign) id<JoinRequestDelegate> delegate;
@property (nonatomic) NSDictionary *request;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userCourse;
@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;

@end
