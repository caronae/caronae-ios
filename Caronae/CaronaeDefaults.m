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
    }
    return self;
}

@end