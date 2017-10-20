import Foundation

class FilterParameters: NSObject {
    var going: Bool?
    var neighborhoods: [String]?
    var selectedZone: String?
    var hubs: [String]?
    var campus: String?
    var date: Date?
    
    init(going: Bool? = nil, neighborhoods: [String]? = nil, zone: String? = nil, hubs: [String]? = nil, campus: String? = nil, date: Date? = nil) {
        self.going = going
        self.neighborhoods = neighborhoods
        self.selectedZone = zone
        self.hubs = hubs
        self.campus = campus
        self.date = date
    }
    
    func dictionary() -> [String: Any] {
        var params: [String: Any] = [:]
        if let going = self.going {
            params["going"] = going
        }
        if let zone = self.selectedZone, !zone.isEmpty, zone != CaronaeAllNeighborhoodsText {
            params["zone"] = zone
            if let neighborhoods = self.neighborhoods?.joined(separator: ", "), neighborhoods != zone {
                // User didn't select all neighborhoods of selected zone
                params["neighborhoods"] = neighborhoods
            }
        }
        if let campus = self.campus, !campus.isEmpty, campus != CaronaeAllCampiText {
            params["campus"] = campus
            if let hubs = self.hubs?.joined(separator: ", "), hubs != campus {
                // User didn't select all hubs of selected campus
                params["hubs"] = hubs
            }
        }
        if let date = self.date {
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "HH:mm"
            let timeString = dateFormatter.string(from: date)
            params["date"] = dateString
            params["time"] = timeString
        }
        return params
    }
    
    func activeFiltersText() -> String {
        var label = String()
        if let zone = self.selectedZone, zone.isEmpty || zone == CaronaeAllNeighborhoodsText {
            label = hubs!.compactString()
        } else if let campus = self.campus, campus.isEmpty || campus == CaronaeAllCampiText {
            label = neighborhoods!.compactString()
        } else {
            label = hubs!.compactString() + ", " + neighborhoods!.compactString()
        }
        return label
    }
    
}

