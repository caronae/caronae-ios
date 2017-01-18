import RealmSwift

extension ChatViewController {
    func loadChatMessages() {
        // Load local messages
        ChatService.instance.messagesForRide(withID: ride.id) { messages, error in
            guard error == nil else {
                NSLog("Whoops, couldn't load: %@", error!.localizedDescription)
                return
            }
            
            self.messages = messages
            self.subscribeToChanges()
        }
        
        // Check for updates
        ChatService.instance.updateMessagesForRide(withID: ride.id) { error in
            guard error == nil else {
                NSLog("Error updating messages for ride %ld. (%@)", self.ride.id, error!.localizedDescription)
                return
            }
            
            NSLog("Updated messages for ride %ld", self.ride.id)
        }
    }
    
    func subscribeToChanges() {
        messagesNotificationToken = messages.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            self?.finishReceivingMessage()
        }
    }
    
    func clearNotifications() {
        NotificationService.instance.clearNotifications(forRideID: ride.id, of: .chat)
    }

}
