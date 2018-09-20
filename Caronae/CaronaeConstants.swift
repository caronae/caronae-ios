import Foundation
// swiftlint:disable identifier_name


// MARK: Caronae API Base URL

#if DEVELOPMENT
    let CaronaeAPIBaseURLString = "https://api.dev.caronae.org"
#elseif TESTING
    let CaronaeAPIBaseURLString = "https://private-443d4-caronae.apiary-mock.com"
#else
    let CaronaeAPIBaseURLString = "https://api.caronae.org"
#endif


// MARK: Static pages URLs

struct CaronaeURLString {
    #if DEVELOPMENT
    static let base = "https://dev.caronae.org"
    #else
    static let base = "https://caronae.org"
    #endif
    static let login = String(format: "%@/login?type=app_jwt", CaronaeAPIBaseURLString)
    static let loginCallback = "caronae://login"
    static let aboutPage = String(format: "%@/sobre_mobile.html", CaronaeURLString.base)
    static let termsOfUsePage = String(format: "%@/termos_mobile.html", CaronaeURLString.base)
    static let FAQPage = String(format: "%@/faq.html?mobile", CaronaeURLString.base)
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
let Caronae9PhoneNumberPattern = "({0}[00]) [00000]-[0000]"
let CaronaeBrazilianCarPlatePattern = "[AAA]{-}[0000]"
let CaronaePlaceholderProfileImage = "Profile Picture"
let CaronaeSearchDateFormat = "EEEE, dd/MM/yyyy HH:mm"
let CaronaeAllNeighborhoodsText = "Todos os Bairros"
let CaronaeAllCampiText = "Todos os Campi"
let CaronaeOtherNeighborhoodsText = "Outros"

let OtherZoneColor = UIColor(white: 0.541, alpha: 1.0)
