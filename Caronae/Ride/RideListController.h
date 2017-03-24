@import UIKit;
#import "RideCell.h"
#import "RideViewController.h"

@class AFHTTPRequestOperation;

@interface RideListController : UIViewController

- (void)loadingFailedWithError:(NSError *)error;
- (void)updateFilteredRides;

- (RideCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic) id rides;
@property (nonatomic, readonly) NSArray<Ride *> *filteredRides;

@property (nonatomic, assign) BOOL hidesDirectionControl;
@property (nonatomic, assign) BOOL ridesDirectionGoing;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) id<UITableViewDelegate> delegate;
@property (nonatomic, strong) id<UITableViewDataSource> dataSource;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filterViewHeightZero;

@property (nonatomic) UILabel *emptyTableLabel;
@property (nonatomic) UILabel *errorLabel;
@property (nonatomic) UILabel *loadingLabel;

@property (nonatomic) IBInspectable BOOL historyTable;
@property (nonatomic) IBInspectable BOOL filterIsEnabled;
@property (nonatomic, strong) IBInspectable NSString *emptyMessage;

@end
