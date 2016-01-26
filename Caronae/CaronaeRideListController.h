#import <UIKit/UIKit.h>

@interface CaronaeRideListController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) id<UITableViewDelegate> delegate;
@property (nonatomic, strong) id<UITableViewDataSource> dataSource;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic) NSArray *rides;
@property (nonatomic) Ride *selectedRide;

@property (weak, nonatomic) IBOutlet UISegmentedControl *directionControl;

@property (nonatomic) UILabel *emptyTableLabel;
@property (nonatomic) UILabel *errorLabel;
@property (nonatomic) UILabel *loadingLabel;

@end
