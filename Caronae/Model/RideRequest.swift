import RealmSwift

class RideRequest: Object {
    dynamic var rideID: Int = 0
    dynamic var date: Date! = Date()
    
    override static func primaryKey() -> String? {
        return "rideID"
    }
    
    convenience init(rideID id: Int) {
        self.init()
        self.rideID = id
    }
}
