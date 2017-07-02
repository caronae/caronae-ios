import Foundation

class NotificationParser {
    static let shared = NotificationParser()
    private init() { }
    
    func handleNotification(_ userInfo: [AnyHashable : Any]?) -> DeeplinkType? {
        guard let msgType = userInfo?["msgType"] as? String else {
            return nil
        }
        
        switch msgType {
        case "joinRequest":
            return .openMyRides
        case "accepted",
             "refused",
             "cancelled",
             "quitter":
            return .openActiveRides
        case "finished":
            return .openRidesHistory
        case "chat":
            guard let idString = userInfo?["rideId"] as? String,
                let id = Int(idString) else {
                    NSLog("Cannot open chat for ride, did not get rideId")
                    return nil
            }
            return .openChatForRide(withID: id)
        default:
            NSLog("Cannot handle notification, msgType unknown")
            return nil
        }
    }
}
