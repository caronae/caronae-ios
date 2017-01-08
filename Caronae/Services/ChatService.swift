import RealmSwift
import Firebase

class ChatService: NSObject {
    static let instance = ChatService()
    let api = CaronaeAPIHTTPSessionManager.instance
    
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    func subscribeToRide(withID id: Int) {
        let topic = topicID(withRideID: id)
        NSLog("Subscribing to \(topic)")
        FIRMessaging.messaging().subscribe(toTopic: topic)
    }
    
    func unsubscribeFromRide(withID id: Int) {
        let topic = topicID(withRideID: id)
        NSLog("Unsubscribing from \(topic)")
        FIRMessaging.messaging().unsubscribe(fromTopic: topic)
    }
    
    // MARK: Message methods
    
    func storeMessage(_ message: Message, forRideID rideID: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(message)
            }
        } catch {
            NSLog("Error saving message. Could not load Realm")
        }
    }
    
    func messagesForRide(withID id: Int, completionBlock: @escaping (Results<Message>?, Error?) -> Void) {
        do {
            let realm = try Realm()
            let messages = realm.objects(Message.self).filter("ride.id == %@", id)
            completionBlock(messages, nil)
        } catch {
            completionBlock(nil, error)
        }
    }
    
    func sendMessage(_ body: String, rideID: Int, completionBlock: @escaping (Message?, Error?) -> Void) {
        let message = Message()
        message.body = body
        message.date = Date()
        message.sender = UserService.instance.user
        
        let chatRoute = "\(CaronaeAPIBaseURL)/ride/\(rideID)/chat"
        let payload = [ "message": message.body ]
        api.post(chatRoute, parameters: payload, success: { operation, responseObject in
            do {
                let realm = try Realm()
                guard let ride = realm.object(ofType: Ride.self, forPrimaryKey: rideID) else {
                    NSLog("Could not find ride to store chat message with ID %ld", rideID)
                    completionBlock(nil, nil)
                    return
                }
                
                message.ride = ride
                
                try realm.write {
                    realm.add(message)
                }
            } catch {
                completionBlock(nil, error)
            }

            completionBlock(message, nil)
        }, failure: { _, err in
            NSLog("Error sending message data: \(err.localizedDescription)")
            completionBlock(nil, err)
        })
    }
    
    private func topicID(withRideID id: Int) -> String {
        return "/topics/\(id)"
    }
}
