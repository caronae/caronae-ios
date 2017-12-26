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

let CaronaeIntranetURLString = "https://api.caronae.com.br/login"
let CaronaeAboutPageURLString = "https://caronae.org/sobre_mobile.html"
let CaronaeTermsOfUsePageURLString = "https://caronae.org/termos_mobile.html"
let CaronaeFAQPageURLString = "https://caronae.org/faq.html?mobile"


// MARK: Notifications

extension Foundation.Notification.Name {
    static let CaronaeDidUpdateNotifications = Foundation.Notification.Name("CaronaeDidUpdateNotifications")
    static let CaronaeDidUpdateUser = Foundation.Notification.Name("CaronaeDidUpdateUserNotification")
}

// MARK: Preference keys

let CaronaePreferenceLastSearchedNeighborhoodsKey = "lastSearchedNeighborhoods"
let CaronaePreferenceLastSearchedZoneKey = "lastSearchedZone"
let CaronaePreferenceLastSearchedCampusKey = "lastSearchedCampus"
let CaronaePreferenceLastSearchedCentersKey = "lastSearchedCenters"
let CaronaePreferenceLastSearchedDateKey = "lastSearchedDate"

let CaronaePreferenceFilterIsEnabledKey = "filterIsEnabled"
let CaronaePreferenceLastFilteredZoneKey = "lastFilteredZone"
let CaronaePreferenceLastFilteredNeighborhoodsKey = "lastFilteredNeighborhoods"
let CaronaePreferenceLastFilteredCampusKey = "lastFilteredCampus"
let CaronaePreferenceLastFilteredCentersKey = "lastFilteredCenters"


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
    static let CaronaeAboutPageURLStringObjc = CaronaeAboutPageURLString as NSString
    static let CaronaeTermsOfUsePageURLStringObjc = CaronaeTermsOfUsePageURLString as NSString
    static let CaronaeFAQPageURLStringObjc = CaronaeFAQPageURLString as NSString
    static let CaronaeDidUpdateUserObjc = Foundation.Notification.Name.CaronaeDidUpdateUser.rawValue as NSString
}
