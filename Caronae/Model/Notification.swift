import RealmSwift

class Notification: Object {
    dynamic var id: String = String()
    dynamic var senderID: Int = 0
    dynamic var rideID: Int = 0
    dynamic var kind: Kind = .other
    dynamic var date: Date! = Date()
    
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

