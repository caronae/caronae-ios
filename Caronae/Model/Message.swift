import ObjectMapper
import RealmSwift

class Message: Object, Mappable {
    dynamic var id: Int = 0
    dynamic var date: Date!
    dynamic var body: String!
    dynamic var sender: User!
    dynamic var ride: Ride!
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        date <- (map["date"], DateTimeTransform())
        body <- map["body"]
        sender <- map["user"]
    }
    
    var incoming: Bool {
        return sender != UserService.instance.user
    }
}

