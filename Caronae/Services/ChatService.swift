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
    
    func messagesForRide(withID rideID: Int, completionBlock: @escaping (Results<Message>?, Error?) -> Void) {
        do {
            let realm = try Realm()
            guard let ride = realm.object(ofType: Ride.self, forPrimaryKey: rideID) else {
                NSLog("Could not find local ride with ID %ld", rideID)
                completionBlock(nil, nil)
                return
            }
            
            let messages = realm.objects(Message.self).filter("ride == %@", ride)
            completionBlock(messages, nil)
        } catch {
            completionBlock(nil, error)
        }
    }
    
    func updateMessagesForRide(withID rideID: Int, completionBlock: @escaping (Error?) -> Void) {
        api.get("/ride/\(rideID)/chat", parameters: nil, success: { _, responseObject in
            guard let jsonResponse = responseObject as? [String: Any],
                let messagesJson = jsonResponse["messages"] as? [[String: Any]] else {
                    NSLog("Error: messages not found in responseObject")
                    completionBlock(nil)
                    return
            }
            
            // Deserialize response
            let messages = messagesJson.flatMap { Message(JSON: $0) }
            
            do {
                let realm = try Realm()
                guard let ride = realm.object(ofType: Ride.self, forPrimaryKey: rideID) else {
                    NSLog("Could not find local ride with ID %ld", rideID)
                    completionBlock(nil)
                    return
                }
            
                messages.forEach { $0.ride = ride }
                
                try realm.write {
                    realm.add(messages, update: true)
                }
            } catch {
                completionBlock(error)
            }
            
            completionBlock(nil)
        }, failure: { _, err in
            NSLog("Error: Failed to get offered rides: \(err.localizedDescription)")
            completionBlock(err)
        })
    }
    
    func sendMessage(_ body: String, rideID: Int, completionBlock: @escaping (Message?, Error?) -> Void) {
        let message = Message()
        message.body = body
        message.date = Date()
        message.sender = UserService.instance.user
        
        let params = [ "message": message.body ]
        api.post("/ride/\(rideID)/chat", parameters: params, success: { _, responseObject in
            guard let response = responseObject as? [String: Any],
                let messageID = response["id"] as? Int else {
                NSLog("Error saving message. Invalid response.")
                completionBlock(nil, nil)
                return
            }
            
            do {
                let realm = try Realm()
                guard let ride = realm.object(ofType: Ride.self, forPrimaryKey: rideID) else {
                    NSLog("Could not find local ride with ID %ld", rideID)
                    completionBlock(nil, nil)
                    return
                }
                
                message.id = messageID
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
