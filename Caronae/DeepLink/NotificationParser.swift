class NotificationParser {
    static let shared = NotificationParser()
    private init() { }
    
    func handleNotification(_ userInfo: [AnyHashable : Any]?) -> DeeplinkType? {
        guard let msgType = userInfo?["msgType"] as? String else {
            return nil
        }
        
        switch msgType {
        case "accepted":
            guard let id = rideId(ofUserInfo: userInfo) else {
                return .openMyRides
            }
            return .loadAcceptedRide(withID: id)
        case "refused",
             "cancelled",
             "quitter":
            return .openMyRides
        case "finished":
            return .openRidesHistory
        case "joinRequest":
            guard let id = rideId(ofUserInfo: userInfo) else {
                return .openMyRides
            }
            return .openRide(withID: id, openChat: false)
        case "chat":
            guard let id = rideId(ofUserInfo: userInfo) else {
                return .openMyRides
            }
            return .openRide(withID: id, openChat: true)
        default:
            NSLog("Cannot handle notification, msgType unknown")
            return nil
        }
    }
    
    private func rideId(ofUserInfo userInfo: [AnyHashable : Any]?) -> Int? {
        guard let idString = userInfo?["rideId"] as? String,
            let id = Int(idString) else {
                NSLog("Cannot handle notification, did not get rideId")
                return nil
        }
        return id
    }
}
