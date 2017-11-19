import RealmSwift

class Notification: Object {
    @objc dynamic var id: String = String()
    @objc dynamic var senderID: Int = 0
    @objc dynamic var rideID: Int = 0
    @objc dynamic var kind: Kind = .other
    @objc dynamic var date: Date! = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    @objc enum Kind: Int {
        case chat
        case rideJoinRequest
        case rideJoinRequestAccepted
        case other
    }
}

