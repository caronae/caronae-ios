extension ChatViewController {
    func loadChatMessages() {
        ChatService.instance.messagesForRide(withID: ride.id) { messages, error in
            guard error == nil else {
                NSLog("Whoops, couldn't load: %@", error!.localizedDescription)
                return
            }
            
            self.messages = messages
        }
    }
}
