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
NSString *const CaronaeAllCampiText = @"Todos os Campi";
NSString *const CaronaeOtherZoneText = @"Outra";
NSString *const CaronaeOtherNeighborhoodsText = @"Outros";


@interface CaronaeConstants ()
@property (nonatomic, readwrite) NSDictionary *placeColors;
@property (nonatomic, readwrite) UIColor *otherZoneColor;
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

- (UIColor *) otherZoneColor {
    if (!_otherZoneColor) {
        _otherZoneColor = [UIColor colorWithWhite:0.541 alpha:1.000];
    }
    return _otherZoneColor;
}

- (NSDictionary *)placeColors {
    if (!_placeColors) {
        _placeColors = @{@"Baixada": [UIColor colorWithRed:0.890 green:0.145 blue:0.165 alpha:1.000],
                        @"Centro": [UIColor colorWithRed:0.906 green:0.424 blue:0.114 alpha:1.000],
                        @"Grande Niterói": [UIColor colorWithRed:0.898 green:0.349 blue:0.620 alpha:1.000],
                        @"Zona Norte": [UIColor colorWithRed:0.353 green:0.157 blue:0.094 alpha:1.000],
                        @"Zona Oeste": [UIColor colorWithRed:0.125 green:0.145 blue:0.467 alpha:1.000],
                        @"Zona Sul": [UIColor colorWithRed:0.114 green:0.655 blue:0.365 alpha:1.000],
                        @"Cidade Universitária": [UIColor colorWithRed:0.353 green:0.157 blue:0.094 alpha:1.000],   // Zona Norte
                        @"Praia Vermelha": [UIColor colorWithRed:0.114 green:0.655 blue:0.365 alpha:1.000]          // Zona Sul
                        };
    }
    return _placeColors;
}

@end
