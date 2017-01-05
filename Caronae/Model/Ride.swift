import ObjectMapper
import RealmSwift

import ObjectMapper
import RealmSwift

class Ride: Object, Mappable {
    dynamic var id: Int = 0
    dynamic var region: String!
    dynamic var neighborhood: String!
    dynamic var place: String!
    dynamic var hub: String!
    dynamic var route: String!
    dynamic var notes: String!
    dynamic var going: Bool = true
    dynamic var date: Date! = Date()
    dynamic var slots: Int = 0
    
    dynamic var weekDays: String?
    dynamic var repeatsUntil: Date?
    var routineID = RealmOptional<Int>()
    
    dynamic var driver: User!
    var riders = List<User>()
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateFormatter = DateFormatterTransform(dateFormatter: formatter)
        
        id <- map["id"]
        region <- map["myzone"]
        neighborhood <- map["neighborhood"]
        place <- map["place"]
        hub <- map["hub"]
        route <- map["route"]
        notes <- map["description"]
        going <- map["going"]
        date <- (map["mydate"], dateFormatter) // FIXME: parse time
        slots <- map["slots"]
        
        routineID <- map["routine_id"]
        weekDays <- map["week_days"]
        repeatsUntil <- (map["repeats_until"], dateFormatter)
        
        driver <- map["driver"]
        riders <- map["riders"]
    }
    
    var title: String {
        if going {
            return String(format: "%@ → %@", neighborhood, hub)
        } else {
            return String(format: "%@ → %@", hub, neighborhood)
        }
    }
    
    var isActive: Bool {
        return riders.count > 0
    }
    
    var isRoutine: Bool {
        return routineID.value != nil
    }
}

