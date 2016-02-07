#import <UIKit/UIKit.h>
#import "CaronaeRideCell.h"

@interface CaronaeRideListController : UIViewController

- (CaronaeRideCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic) NSArray *rides;
@property (nonatomic, readonly) NSArray *filteredRides;

@property (nonatomic) Ride *selectedRide;

@property (nonatomic) BOOL ridesDirectionGoing;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) id<UITableViewDelegate> delegate;
@property (nonatomic, strong) id<UITableViewDataSource> dataSource;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionControl;

@property (nonatomic) UILabel *emptyTableLabel;
@property (nonatomic) UILabel *errorLabel;
@property (nonatomic) UILabel *loadingLabel;

@property (nonatomic) IBInspectable BOOL historyTable;

@end
