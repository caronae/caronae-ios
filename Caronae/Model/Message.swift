import ObjectMapper
import RealmSwift

class Message: Object, Mappable {
    @objc dynamic var id: Int = 0
    @objc dynamic var date: Date!
    @objc dynamic var body: String!
    @objc dynamic var sender: User!
    @objc dynamic var ride: Ride!
    
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

