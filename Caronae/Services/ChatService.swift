import RealmSwift
import Firebase

class ChatService: NSObject {
    static let instance = ChatService()
    private let api = CaronaeAPIHTTPSessionManager.instance
    
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
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
        // Load the Ride object
        guard let realm = try? Realm(),
            let ride = realm.object(ofType: Ride.self, forPrimaryKey: rideID) else {
            NSLog("Could not load local ride with ID %ld", rideID)
            completionBlock(nil)
            return
        }
        
        // Query only the messages since the date of the last known message by someone else
        var params: [String: Any]?
        if let user = UserService.instance.user,
            let lastMessage = realm.objects(Message.self)
                .filter("ride == %@ AND sender != %@", ride, user)
                .sorted(byKeyPath: "date", ascending: false)
                .first {
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            params = [ "since": dateFormatter.string(from: lastMessage.date) ]
        }
        
        api.get("/ride/\(rideID)/chat", parameters: params, success: { _, responseObject in
            guard let jsonResponse = responseObject as? [String: Any],
                let messagesJson = jsonResponse["messages"] as? [[String: Any]] else {
                    completionBlock(CaronaeError.invalidResponse)
                    return
            }
            
            // Deserialize response
            let messages = messagesJson.flatMap {
                let message = Message(JSON: $0)
                message?.ride = ride
                return message
            } as [Message]
            
            // Persist
            do {
                try realm.write {
                    realm.add(messages, update: true)
                }
            } catch {
                completionBlock(error)
            }
            
            completionBlock(nil)
        }, failure: { _, err in
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
                completionBlock(nil, CaronaeError.invalidResponse)
                return
            }
            
            // Persist
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
}
