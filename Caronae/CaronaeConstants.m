#import "CaronaeConstants.h"

#pragma mark - Static pages URLs

NSString *const CaronaeIntranetURLString = @"https://api.caronae.com.br/login";
NSString *const CaronaeAboutPageURLString = @"https://api.caronae.ufrj.br/static_pages/sobre.html";
NSString *const CaronaeTermsOfUsePageURLString = @"https://api.caronae.ufrj.br/static_pages/termos.html";
NSString *const CaronaeFAQPageURLString = @"https://api.caronae.ufrj.br/static_pages/faq.html";


#pragma mark - Notifications

NSNotificationName const CaronaeNotificationReceivedNotification = @"CaronaeNotificationReceivedNotification";
NSNotificationName const CaronaeDidUpdateNotifications = @"CaronaeDidUpdateNotifications";
NSNotificationName const CaronaeDidUpdateUserNotification = @"CaronaeDidUpdateUserNotification";


#pragma mark - Preference keys

NSString *const CaronaePreferenceLastSearchedNeighborhoodsKey = @"lastSearchedNeighborhoods";
NSString *const CaronaePreferenceLastSearchedZoneKey = @"lastSearchedZone";
NSString *const CaronaePreferenceLastSearchedCampusKey = @"lastSearchedCampus";
NSString *const CaronaePreferenceLastSearchedCentersKey = @"lastSearchedCenters";
NSString *const CaronaePreferenceLastSearchedDateKey = @"lastSearchedDate";

NSString *const CaronaePreferenceFilterIsEnabledKey = @"filterIsEnabled";
NSString *const CaronaePreferenceLastFilteredZoneKey = @"lastFilteredZone";
NSString *const CaronaePreferenceLastFilteredNeighborhoodsKey = @"lastFilteredNeighborhoods";
NSString *const CaronaePreferenceLastFilteredCampusKey = @"lastFilteredCampus";
NSString *const CaronaePreferenceLastFilteredCentersKey = @"lastFilteredCenters";


#pragma mark - Etc.

NSString *const CaronaeErrorDomain = @"br.ufrj.caronae.error";
NSString *const CaronaeSignOutRequiredKey = @"CaronaeSignOutRequired";
NSString *const Caronae8PhoneNumberPattern = @"(###) ####-####";
NSString *const Caronae9PhoneNumberPattern = @"(###) #####-####";
NSString *const CaronaePlaceholderProfileImage = @"Profile Picture";
NSString *const CaronaeSearchDateFormat = @"EEEE, dd/MM/yyyy HH:mm";
NSString *const CaronaeDateLocaleIdentifier = @"pt_BR";
NSString *const CaronaeAllNeighborhoodsText = @"Todos os Bairros";
NSString *const CaronaeAllCampusesText = @"Todos os Campi";


@interface CaronaeConstants ()
@property (nonatomic, readwrite) NSArray *campuses;
@property (nonatomic, readwrite) NSDictionary *campusColors;
@property (nonatomic, readwrite) NSDictionary *centers;
@property (nonatomic, readwrite) NSDictionary *hubs;
@property (nonatomic, readwrite) NSArray *zones;
@property (nonatomic, readwrite) NSDictionary *zoneColors;
@property (nonatomic, readwrite) NSDictionary *neighborhoods;
@end

@implementation CaronaeConstants

+ (instancetype)defaults {
    static CaronaeConstants *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

+ (UIColor *)colorForZone:(NSString *)zone {
    UIColor *color = [CaronaeConstants defaults].zoneColors[zone];
    if (!color) color = [UIColor darkGrayColor];
    return color;
}

- (NSArray *)zones {
    if (!_zones) {
        _zones = @[@"Baixada", @"Centro", @"Grande Niterói", @"Zona Norte", @"Zona Oeste", @"Zona Sul", @"Outra"];
    }
    return _zones;
}

- (NSDictionary *)zoneColors {
    if (!_zoneColors) {
        _zoneColors = @{@"Baixada": [UIColor colorWithRed:0.890 green:0.145 blue:0.165 alpha:1.000],
                        @"Centro": [UIColor colorWithRed:0.906 green:0.424 blue:0.114 alpha:1.000],
                        @"Grande Niterói": [UIColor colorWithRed:0.898 green:0.349 blue:0.620 alpha:1.000],
                        @"Zona Norte": [UIColor colorWithRed:0.353 green:0.157 blue:0.094 alpha:1.000],
                        @"Zona Oeste": [UIColor colorWithRed:0.125 green:0.145 blue:0.467 alpha:1.000],
                        @"Zona Sul": [UIColor colorWithRed:0.114 green:0.655 blue:0.365 alpha:1.000],
                        @"Outra": [UIColor colorWithWhite:0.541 alpha:1.000]
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
                NSLog(@"Error: %@", readError.localizedDescription);
            }
        }
        _neighborhoods = neighborhoods;
    }
    return _neighborhoods;
}

- (NSDictionary *)campusColors {
    if (!_campusColors) {
        _campusColors = @{@"Cidade Universitária": [CaronaeConstants colorForZone:@"Zona Norte"],
                        @"Praia Vermelha": [CaronaeConstants colorForZone:@"Zona Sul"],
                        };
    }
    return _campusColors;
}

- (NSDictionary *)centers {
    if (!_centers) {
        _centers = @{@"Cidade Universitária": @[@"CT", @"CCMN", @"CCS", @"EEFD", @"Reitoria", @"Letras"]
                     };
    }
    return _centers;
}

- (NSDictionary *)hubs {
    if (!_hubs) {
        _hubs = @{@"Cidade Universitária": @[@"CT: Bloco A", @"CT: Bloco D", @"CT: Bloco H", @"CCMN: Frente", @"CCMN: Fundos", @"Letras", @"Reitoria", @"EEFD", @"CCS: Frente", @"CCS: HUCFF"],
                  @"Praia Vermelha": @[@"Hub - Frente", @"Hub - Trás"]
                  };
    }
    return _hubs;
}

- (NSArray *)campuses {
    if (!_campuses) {
        _campuses = @[@"Cidade Universitária", @"Praia Vermelha"];
    }
    return _campuses;
}

@end
