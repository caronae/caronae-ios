#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "RidesHistoryViewController.h"
#import "CaronaeAlertController.h"
#import "CaronaeRideCell.h"
#import "RideViewController.h"
#import "Ride.h"

@interface RidesHistoryViewController ()

@end

@implementation RidesHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadRidesHistory];
}


#pragma mark - Rides methods

- (void)loadRidesHistory {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [manager GET:[CaronaeAPIBaseURL stringByAppendingString:@"/ride/getRidesHistory"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *responseError;
        NSArray *rides = [RidesHistoryViewController parseResultsFromResponse:responseObject withError:&responseError];
        if (!responseError) {
            NSLog(@"Rides history returned %lu rides.", (unsigned long)rides.count);
            self.rides = rides;
            if (self.rides.count > 0) {
                self.tableView.backgroundView = nil;
            }
            else {
                self.tableView.backgroundView = self.emptyTableLabel;
            }
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.tableView.backgroundView = self.errorLabel;
        
        if (operation.response.statusCode == 403) {
            [CaronaeAlertController presentOkAlertWithTitle:@"Erro de autorização" message:@"Ocorreu um erro autenticando seu usuário. Seu token pode ter sido suspenso ou expirado." handler:^{
                [CaronaeDefaults signOut];
            }];
        }
        else {
            NSLog(@"Error loading rides history: %@", error.localizedDescription);
        }
    }];
}

+ (NSArray *)parseResultsFromResponse:(id)responseObject withError:(NSError *__autoreleasing *)err {
    // Check if we received an array of the rides
    if ([responseObject isKindOfClass:NSArray.class]) {
        NSMutableArray *rides = [NSMutableArray arrayWithCapacity:((NSArray*)responseObject).count];
        for (NSDictionary *rideDictionary in responseObject) {
            Ride *ride = [[Ride alloc] initWithDictionary:rideDictionary];
            [rides addObject:ride];
        }
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        return [rides sortedArrayUsingDescriptors:@[sortDescriptor]];
    }
    else {
        if (err) {
            NSDictionary *errorInfo = @{
                                        NSLocalizedDescriptionKey: NSLocalizedString(@"Unexpected server response.", nil)
                                        };
            *err = [NSError errorWithDomain:CaronaeErrorDomain code:CaronaeErrorInvalidResponse userInfo:errorInfo];
        }
    }
    
    return nil;
}

@end
