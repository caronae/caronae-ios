import ObjectMapper
import RealmSwift

class Zone: Object, Mappable {
    dynamic var name: String!
    dynamic var hexColor: String!
    lazy var color: UIColor = {
        return UIColor(hex: self.hexColor)
    }()
    var neighborhoodsList = List<Place>()
    var neighborhoods: [String] {
        get { return neighborhoodsList.flatMap { $0.name } }
        set { newValue.forEach { neighborhoodsList.append(Place(name: $0, category: .neighborhood)) } }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["color", "neighborhoods"]
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        hexColor <- map["color"]
        neighborhoods <- map["neighborhoods"]
    }
}
