import RealmSwift

class RideRequest: Object {
    @objc dynamic var rideID: Int = 0
    @objc dynamic var date: Date! = Date()
    
    override static func primaryKey() -> String? {
        return "rideID"
    }
    
    convenience init(rideID id: Int) {
        self.init()
        self.rideID = id
    }
}
