import CoreData
import Firebase

class ChatService: NSObject {
    static let sharedInstance = ChatService()
    private var chats: [Ride: Chat] = [:]
    
    private override init() { }
    
    func chat(forRide ride: Ride) -> Chat? {
        if let chat = chats[ride] {
            return chat
        }
        
        let chat = Chat(withRide: ride)
        setChat(chat, forRide: ride)
        return chat
    }
    
    func setChat(_ chat: Chat, forRide ride: Ride) {
        chats[ride] = chat
    }
    
    func subscribeToChat(_ chat: Chat) {
        NSLog("Subscribing to \(chat.topicID)")
        FIRMessaging.messaging().subscribe(toTopic: chat.topicID)
    }
    
    func unsubscribeFromChat(_ chat: Chat) {
        NSLog("Unsubscribing from \(chat.topicID)")
        FIRMessaging.messaging().unsubscribe(fromTopic: chat.topicID)
    }
    
    func removeAllChats() {
        chats.forEach { (ride, chat) in
            unsubscribeFromChat(chat)
        }
        
        chats.removeAll()
    }
    
    
    // MARK: Message methods
    
    func messagesForChat(_ chat: Chat, completionBlock: @escaping ([Message]?, Error?) -> Void) {
        let request: NSFetchRequest<Message> = NSFetchRequest(entityName: NSStringFromClass(Message.self))
        request.predicate = NSPredicate(format: "rideID == %@", chat.ride.rideID as NSNumber)
        request.sortDescriptors = [NSSortDescriptor(key: "sentDate", ascending: true)]
        
        do {
            let messages = try self.context.fetch(request)
            completionBlock(messages, nil)
        } catch let error {
            completionBlock(nil, error)
        }
    }
    
    func sendMessage(_ body: String, inChat chat: Chat, completionBlock: @escaping (Message?, Error?) -> Void) {
        let currentUser = UserController.sharedInstance().user!
        
        let message = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Message.self), into: context) as! Message
        message.text = body
        message.incoming = false
        message.sentDate = Date()
        message.rideID = chat.ride.rideID as NSNumber
        message.senderId = currentUser.userID
        message.senderName = currentUser.name
        
        let chatRoute = "\(CaronaeAPIBaseURL)/ride/\(chat.ride.rideID)/chat"
        let payload = [ "message": message.text ]
        CaronaeAPIHTTPSessionManager.instance.post(chatRoute, parameters: payload, success: { operation, responseObject in
            
            do {
                try self.context.save()
            } catch let error {
                completionBlock(nil, error)
            }
            
            completionBlock(message, nil)
            
        }) { operation, error in
            NSLog("Error sending message data: \(error.localizedDescription)")
            
            completionBlock(nil, error)
        }
    }
    
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    }
}

extension Chat {
    fileprivate var topicID: String {
        return "/topics/\(ride.rideID)"
    }
}
