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
    dynamic var driver: User!
    var routineID = RealmOptional<Int>()
    var riders = List<User>()
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        region <- map["myzone"]
        neighborhood <- map["neighborhood"]
        place <- map["place"]
        hub <- map["hub"]
        route <- map["route"]
        notes <- map["description"]
        going <- map["going"]
//        date <- map["mydate"] // FIXME: parse date and time to a single property
        slots <- map["slots"]
        driver <- map["driver"]
        riders <- map["riders"]
        routineID <- map["routine_id"]
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

