#import "CaronaeDefaults.h"

#pragma mark - API settings

// NSString *const CaronaeAPIBaseURL = @"http://45.55.46.90:8080";
NSString *const CaronaeAPIBaseURL = @"http://192.168.1.19:8000";
// NSString *const CaronaeAPIBaseURL = @"http://localhost:8000";

#pragma mark - Notifications
NSString *const CaronaeUserRidesUpdatedNotification = @"CaronaeUserRidesUpdatedNotification";

#pragma mark - Error types

NSString *const CaronaeErrorDomain = @"CaronaeError";
const NSInteger CaronaeErrorInvalidResponse = 1;
const NSInteger CaronaeErrorNoRidesCreated = 2;

@implementation CaronaeDefaults

+ (instancetype)defaults {
    static CaronaeDefaults *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _centers = @[@"CT", @"CCMN", @"CCS", @"EEFD", @"Reitoria", @"Letras"];
        _hubs = @[@"CT Fundos Bloco I", @"CT Bloco D", @"CT Bloco H", @"CCMN Frente", @"CCMN Fundos", @"CCS Frente", @"CCS Saída HU", @"Reitoria", @"EEFD", @"Letras"];
        _zones = @[@"Baixada Fluminense", @"Centro", @"Grande Niterói", @"Zona Norte", @"Zona Oeste", @"Zona Sul", @"Outra"];
        _zoneColors = @{@"Baixada Fluminense": [UIColor colorWithRed:0.890 green:0.145 blue:0.165 alpha:1.000],
                        @"Centro":  [UIColor colorWithRed:0.906 green:0.424 blue:0.114 alpha:1.000],
                        @"Grande Niterói":  [UIColor colorWithRed:0.898 green:0.349 blue:0.620 alpha:1.000],
                        @"Zona Norte":  [UIColor colorWithRed:0.353 green:0.157 blue:0.094 alpha:1.000],
                        @"Zona Oeste":  [UIColor colorWithRed:0.125 green:0.145 blue:0.467 alpha:1.000],
                        @"Zona Sul":  [UIColor colorWithRed:0.114 green:0.655 blue:0.365 alpha:1.000],
                        @"Outra":  [UIColor colorWithWhite:0.541 alpha:1.000]
                        };
    }
    return self;
}

@end