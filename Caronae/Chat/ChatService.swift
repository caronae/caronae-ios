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
}

extension Chat {
    fileprivate var topicID: String {
        return "/topics/\(ride.rideID)"
    }
}
