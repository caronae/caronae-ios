import Foundation


// MARK: Caronae API Base URL

#if DEVELOPMENT
    let CaronaeAPIBaseURL = URL(string: "https://api.dev.caronae.org")
#elseif TESTING
    let CaronaeAPIBaseURL = URL(string: "https://private-443d4-caronae.apiary-mock.com")
#else
    let CaronaeAPIBaseURL = URL(string: "https://api.caronae.com.br")
#endif


// MARK: Static pages URLs

struct CaronaeURLString {
    static let intranet = "https://api.caronae.com.br/login"
    static let aboutPage = "https://caronae.org/sobre_mobile.html"
    static let termsOfUsePage = "https://caronae.org/termos_mobile.html"
    static let FAQPage = "https://caronae.org/faq.html?mobile"
}


// MARK: Notifications

extension Foundation.Notification.Name {
    static let CaronaeDidUpdateNotifications = Foundation.Notification.Name("CaronaeDidUpdateNotifications")
    static let CaronaeDidUpdateUser = Foundation.Notification.Name("CaronaeDidUpdateUserNotification")
}

// MARK: Preference keys

struct CaronaePreferenceLastSearch {
    static let zoneKey = "lastSearchedZone"
    static let neighborhoodsKey = "lastSearchedNeighborhoods"
    static let campusKey = "lastSearchedCampus"
    static let centersKey = "lastSearchedCenters"
    static let dateKey = "lastSearchedDate"
}

struct CaronaePreferenceLastOfferedRide {
    static let key = "lastOfferedRide"
    static let zone = "zone"
    static let neighborhood = "neighborhood"
    static let place = "place"
    static let route = "route"
    static let slots = "slots"
    static let description = "description"
    static let hubGoing = "hubGoing"
    static let hubReturning = "hubReturning"
}

struct CaronaePreferenceLastFilter {
    static let isEnabledKey = "filterIsEnabled"
    static let zoneKey = "lastFilteredZone"
    static let neighborhoodsKey = "lastFilteredNeighborhoods"
    static let campusKey = "lastFilteredCampus"
    static let centersKey = "lastFilteredCenters"
    
}


// MARK: Etc.

let CaronaeErrorDomain = "br.ufrj.caronae.error"
let CaronaeSignOutRequiredKey = "CaronaeSignOutRequired"
let Caronae8PhoneNumberPattern = "(###) ####-####"
let Caronae9PhoneNumberPattern = "(###) #####-####"
let CaronaePlaceholderProfileImage = "Profile Picture"
let CaronaeSearchDateFormat = "EEEE, dd/MM/yyyy HH:mm"
let CaronaeDateLocaleIdentifier = "pt_BR"
let CaronaeAllNeighborhoodsText = "Todos os Bairros"
let CaronaeAllCampiText = "Todos os Campi"
let CaronaeOtherZoneText = "Outra"
let CaronaeOtherNeighborhoodsText = "Outros"

let OtherZoneColor = UIColor(white: 0.541, alpha: 1.0)


// MARK: For Objective-C Files

@objcMembers
public class Constants: NSObject {
    static let Caronae8PhoneNumberPatternObjc = Caronae8PhoneNumberPattern as NSString
    static let Caronae9PhoneNumberPatternObjc = Caronae9PhoneNumberPattern as NSString
    static let CaronaePlaceholderProfileImageObjc = CaronaePlaceholderProfileImage as NSString
    static let CaronaeAboutPageURLStringObjc = CaronaeURLString.aboutPage as NSString
    static let CaronaeTermsOfUsePageURLStringObjc = CaronaeURLString.termsOfUsePage as NSString
    static let CaronaeFAQPageURLStringObjc = CaronaeURLString.FAQPage as NSString
    static let CaronaeDidUpdateUserObjc = Foundation.Notification.Name.CaronaeDidUpdateUser.rawValue as NSString
}
