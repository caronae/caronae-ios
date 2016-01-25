#import <UIKit/UIKit.h>

@interface AllRidesViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) id<UITableViewDelegate> delegate;
@property (nonatomic, strong) id<UITableViewDataSource> dataSource;
@end
