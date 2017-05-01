import Foundation

class FilterParameters: NSObject {
    var going: Bool?
    var neighborhoods: [String]?
    var selectedZone: String?
    var hubs: [String]?
    var date: Date?
    
    init(going: Bool? = nil, neighborhoods: [String]? = nil, zone: String? = nil, hubs: [String]? = nil, date: Date? = nil) {
        self.going = going
        self.neighborhoods = neighborhoods
        self.selectedZone = zone
        self.hubs = hubs
        self.date = date
    }
    
    func dictionary() -> [String: Any] {
        var params: [String: Any] = [:]
        if let going = self.going {
            params["going"] = going
        }
        if let zone = self.selectedZone, !zone.isEmpty {
            params["zone"] = zone
            if let neighborhoods = self.neighborhoods?.joined(separator: ", "), neighborhoods != zone {
                // User didn't select all neighborhoods of selected zone
                params["neighborhoods"] = neighborhoods
            }
        }
        if let hubs = self.hubs {
            params["hubs"] = (hubs == [CaronaeAllHubsText]) ? "" : hubs.joined(separator: ", ")
        }
        if let date = self.date {
            let dateFormatter = DateFormatter()
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
        let label = self.hubs!.compactString() + ", " + self.neighborhoods!.compactString()
        return label
    }
    
    func setGoing(_ bool: Bool) {
        self.going = bool
    }
    
}

