import RealmSwift

class NotificationService: NSObject {
    static let instance = NotificationService()
    
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    func getNotifications(of kind: Notification.Kind? = nil) throws -> Results<Notification> {
        let realm = try Realm()
        
        var notifications = realm.objects(Notification.self)
        if let kind = kind {
            notifications = notifications.filter("kind == %@", kind.rawValue)
        }
        return notifications
    }
    
    func createNotification(_ notification: Notification) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(notification, update: true)
            }
        } catch {
            NSLog("Error creating notification (%@)", error.localizedDescription)
        }
        
        notifyObservers()
    }
    
    func clearNotifications(forRideID rideID: Int? = nil, of kind: Notification.Kind? = nil) {
        do {
            let realm = try Realm()
            var notifications = realm.objects(Notification.self)
            if let rideID = rideID {
                notifications = notifications.filter("rideID == %@", rideID)
            }
            if let kind = kind {
                notifications = notifications.filter("kind == %@", kind.rawValue)
            }
            
            try realm.write {
                realm.delete(notifications)
            }
        } catch {
            NSLog("Error deleting notifications (%@)", error.localizedDescription)
        }
        
        notifyObservers()
    }
    
    private func notifyObservers() {
        NotificationCenter.default.post(name: Foundation.Notification.Name.CaronaeDidUpdateNotifications, object: self)
    }
}
