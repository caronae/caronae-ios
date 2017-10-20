import ObjectMapper
import RealmSwift

class Campus: Object, Mappable {
    @objc dynamic var name: String!
    @objc dynamic var hexColor: String!
    lazy var color: UIColor = {
        return UIColor(hex: self.hexColor)
    }()
    var hubsList = List<Place>()
    var hubs: [String] {
        get { return hubsList.flatMap { $0.name } }
        set { newValue.forEach { hubsList.append(Place(name: $0, category: .hub)) } }
    }
    var centersList = List<Place>()
    var centers: [String] {
        get { return centersList.flatMap { $0.name } }
        set { newValue.forEach { centersList.append(Place(name: $0, category: .center)) } }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["color", "hubs", "centers"]
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        hexColor <- map["color"]
        hubs <- map["hubs"]
        centers <- map["centers"]
    }
}
