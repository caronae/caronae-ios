import ObjectMapper
import RealmSwift

class User: Object, Mappable {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String!
    @objc dynamic var profile: String!
    @objc dynamic var course: String!
    @objc dynamic var email: String?
    @objc dynamic var phoneNumber: String?
    @objc dynamic var location: String?
    @objc dynamic var carOwner: Bool = false
    @objc dynamic var carModel: String? = nil
    @objc dynamic var carPlate: String?
    @objc dynamic var carColor: String?
    @objc dynamic var profilePictureURL: String?
    @objc dynamic var facebookID: String!
    @objc dynamic var createdAt: Date!
    @objc dynamic var numRides: Int = 0
    @objc dynamic var numDrives: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        profile <- map["profile"]
        course <- map["course"]
        email <- map["email"]
        phoneNumber <- map["phone_number"]
        location <- map["location"]
        carOwner <- map["car_owner"]
        carModel <- map["car_model"]
        carPlate <- map["car_plate"]
        carColor <- map["car_color"]
        profilePictureURL <- map["profile_pic_url"]
        facebookID <- map["face_id"]
        createdAt <- (map["created_at"], DateTimeTransform())
        numRides <- map["numRides"]
        numDrives <- map["numDrives"]
    }
    
    var firstName: String {
        return name.components(separatedBy: " ").first ?? name
    }
    
    var shortName: String {
        let names = name.components(separatedBy: " ")
        guard let firstName = names.first, let lastName = names.last, lastName != firstName else { return name }
        return firstName + " " + lastName
    }
    
    var isProfileIncomplete: Bool {
        return (phoneNumber?.isEmpty ?? true) || (email?.isEmpty ?? true) || (location?.isEmpty ?? true)
    }
}
