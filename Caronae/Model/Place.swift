import ObjectMapper
import RealmSwift

class Place: Object {
    dynamic var name: String!
    dynamic var category: PlaceCategory = .neighborhood
    
    required convenience init(name: String, category: PlaceCategory) {
        self.init()
        self.name = name
        self.category = category
    }
    
    @objc enum PlaceCategory: Int {
        case hub
        case center
        case neighborhood
    }
}
