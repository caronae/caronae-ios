#import "CaronaeConstants.h"

#pragma mark - Static pages URLs

NSString *const CaronaeIntranetURLString = @"https://api.caronae.com.br/login";
NSString *const CaronaeAboutPageURLString = @"https://caronae.com.br/sobre_mobile.html";
NSString *const CaronaeTermsOfUsePageURLString = @"https://caronae.com.br/termos_mobile.html";
NSString *const CaronaeFAQPageURLString = @"https://caronae.com.br/faq.html?mobile";


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

@end
