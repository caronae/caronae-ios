import Foundation

class FilterParameters: NSObject {
    var going: Bool?
    var neighborhoods: [String]?
    var selectedZone: String?
    var hub: String?
    var date: Date?
    
    init(going: Bool? = nil, neighborhoods: [String]? = nil, zone: String? = nil, hub: String? = nil, date: Date? = nil) {
        self.going = going
        self.neighborhoods = neighborhoods
        self.selectedZone = zone
        self.hub = hub
        self.date = date
    }
    
    func dictionary() -> [String: Any] {
        var params: [String: Any] = [:]
        if let going = self.going {
            params["going"] = going
        }
        if let neighborhoods = self.neighborhoods {
            params["neighborhoods"] = neighborhoods.joined(separator: ", ")
        }
        if let zone = self.selectedZone {
            params["zone"] = zone
        }
        if let hub = self.hub {
            params["hub"] = hub
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
    
    func setGoing(bool: Bool) {
        self.going = bool
    }
    
}

