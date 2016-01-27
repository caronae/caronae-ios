#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "CaronaeDefaults.h"
#import "Ride.h"
#import "AppDelegate.h"

#pragma mark - API settings

//NSString *const CaronaeAPIBaseURL = @"http://web1.tic.ufrj.br/caronae";
NSString *const CaronaeAPIBaseURL = @"http://45.55.46.90";
//NSString *const CaronaeAPIBaseURL = @"http://45.55.46.90:8080";
//NSString *const CaronaeAPIBaseURL = @"http://192.168.1.19:8000";
//NSString *const CaronaeAPIBaseURL = @"http://localhost:8000";


#pragma mark - Notifications

NSString *const CaronaeUserRidesUpdatedNotification = @"CaronaeUserRidesUpdatedNotification";


#pragma mark - Error types

NSString *const CaronaeErrorDomain = @"CaronaeError";
const NSInteger CaronaeErrorInvalidResponse = 1;
const NSInteger CaronaeErrorNoRidesCreated = 2;

@interface CaronaeDefaults()
@property (nonatomic, readwrite) NSArray *centers;
@property (nonatomic, readwrite) NSArray *hubs;
@property (nonatomic, readwrite) NSArray *zones;
@property (nonatomic, readwrite) NSDictionary *zoneColors;
@property (nonatomic, readwrite) NSDictionary *neighborhoods;
@end


@implementation CaronaeDefaults

+ (instancetype)defaults {
    static CaronaeDefaults *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

+ (void)signOut {
    [CaronaeDefaults defaults].user = nil;
    [CaronaeDefaults defaults].userToken = nil;
    [CaronaeDefaults defaults].cachedJoinRequests = nil;
    [[[FBSDKLoginManager alloc] init] logOut];

    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UIViewController *topViewController = [appDelegate topViewController];
    UIViewController *authViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"InitialTokenScreen"];
    authViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [topViewController presentViewController:authViewController animated:YES completion:nil];
}

+ (NSString *)userFBToken {
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    return token.tokenString;
}

+ (BOOL)userProfileIsIncomplete {
    NSDictionary *user = [CaronaeDefaults defaults].user;
    return [user[@"phone_number"] isEqualToString:@""] || [user[@"email"] isEqualToString:@""] || [user[@"location"] isEqualToString:@""];
}

+ (BOOL)hasUserAlreadyRequestedJoin:(Ride *)ride {
    NSArray *requested = [CaronaeDefaults defaults].cachedJoinRequests;
    NSNumber *rideID = @(ride.rideID);
    if ([requested indexOfObject:rideID] != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (void)addToCachedJoinRequests:(Ride *)ride {
    NSMutableArray *requested = [CaronaeDefaults defaults].cachedJoinRequests.mutableCopy;
    NSNumber *rideID = @(ride.rideID);
    [requested addObject:rideID];
    [CaronaeDefaults defaults].cachedJoinRequests = requested;
}

+ (UIColor *)colorForZone:(NSString *)zone {
    UIColor *color = [CaronaeDefaults defaults].zoneColors[zone];
    if (!color) color = [UIColor darkTextColor];
    return color;
}

- (NSArray *)centers {
    if (!_centers) {
        _centers = @[@"CT", @"CCMN", @"CCS", @"EEFD", @"Reitoria", @"Letras"];
    }
    return _centers;
}

- (NSArray *)hubs {
    if (!_hubs) {
        _hubs = @[@"CT: Bloco A", @"CT: Bloco D", @"CT: Bloco H", @"CCMN: Frente", @"CCMN: Fundos", @"Letras", @"Reitoria", @"EEFD", @"CCS: Frente", @"CCS: HU"];
    }
    return _hubs;
}

- (NSArray *)zones {
    if (!_zones) {
        _zones = @[@"Baixada Fluminense", @"Centro", @"Grande Niterói", @"Zona Norte", @"Zona Oeste", @"Zona Sul", @"Outra"];
    }
    return _zones;
}

- (NSDictionary *)zoneColors {
    if (!_zoneColors) {
        _zoneColors = @{@"Baixada Fluminense": [UIColor colorWithRed:0.890 green:0.145 blue:0.165 alpha:1.000],
                        @"Centro":  [UIColor colorWithRed:0.906 green:0.424 blue:0.114 alpha:1.000],
                        @"Grande Niterói":  [UIColor colorWithRed:0.898 green:0.349 blue:0.620 alpha:1.000],
                        @"Zona Norte":  [UIColor colorWithRed:0.353 green:0.157 blue:0.094 alpha:1.000],
                        @"Zona Oeste":  [UIColor colorWithRed:0.125 green:0.145 blue:0.467 alpha:1.000],
                        @"Zona Sul":  [UIColor colorWithRed:0.114 green:0.655 blue:0.365 alpha:1.000],
                        @"Outra":  [UIColor colorWithWhite:0.541 alpha:1.000]
                        };
    }
    return _zoneColors;
}

- (NSDictionary *)neighborhoods {
    if (!_neighborhoods) {
        NSMutableDictionary *neighborhoods = [NSMutableDictionary dictionaryWithCapacity:7];
        NSString *pathName = [[NSBundle mainBundle] pathForResource:@"bairros" ofType:@"csv"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:pathName]) {
            NSError *readError;
            NSString *content = [NSString stringWithContentsOfFile:pathName encoding:NSUTF8StringEncoding error:&readError];
            if (!readError) {
                NSArray *lines = [content componentsSeparatedByString:@"\r\n"];
                for (NSString *line in lines) {
                    NSArray *items = [line componentsSeparatedByString:@","];
                    NSString *zone = items[0];
                    NSString *neighborhood = items[1];
                    if (!neighborhoods[zone]) {
                        neighborhoods[zone] = [NSMutableArray arrayWithCapacity:15];
                    }
                    [neighborhoods[zone] addObject:neighborhood];
                }
            }
            else {
                NSLog(@"Error: %@", readError.description);
            }

        }
        _neighborhoods = neighborhoods;
    }
    return _neighborhoods;
}

- (NSDictionary *)user {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
}

- (void)setUser:(NSDictionary *)user {
    [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)userToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
}

- (void)setUserToken:(NSString *)userToken {
    [[NSUserDefaults standardUserDefaults] setObject:userToken forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)cachedJoinRequests {
    id saved = [[NSUserDefaults standardUserDefaults] objectForKey:@"cachedJoinRequests"];
    // Create empty dictionary if an old one wasn't found
    if (!saved || ![saved isKindOfClass:[NSArray class]]) {
        saved = [[NSArray alloc] init];
        [self setCachedJoinRequests:saved];
    }
    return saved;
}

- (void)setCachedJoinRequests:(NSArray *)cachedJoinRequests {
    [[NSUserDefaults standardUserDefaults] setObject:cachedJoinRequests forKey:@"cachedJoinRequests"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end