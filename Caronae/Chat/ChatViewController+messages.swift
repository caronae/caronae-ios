import RealmSwift

extension ChatViewController {
    func loadChatMessages() {
        ChatService.instance.messagesForRide(withID: ride.id) { messages, error in
            guard error == nil else {
                NSLog("Whoops, couldn't load: %@", error!.localizedDescription)
                return
            }
            
            self.messages = messages
            self.subscribeToChanges()
        }
    }
    
    func sendMessage() {
        // Hack to trigger autocorrect before sending the text
        textView.resignFirstResponder()
        textView.becomeFirstResponder()
        
        let messageText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else { return }
        
        sendButton.isEnabled = false
        
        ChatService.instance.sendMessage(messageText, rideID: ride.id) { message, error in
            self.sendButton.isEnabled = false
            guard error == nil else {
                NSLog("Error sending message data: (%@)", error!.localizedDescription)
                CaronaeAlertController.presentOkAlert(withTitle: "Ops!", message: "Ocorreu um erro enviando sua mensagem.")
                return
            }
            
            self.textView.text = ""            
        }
    }
    
    func subscribeToChanges() {
        guard let messages = messages as? Results<Message> else { return }
        
        messagesNotificationToken = messages.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
                self?.scrollToBottom(animated: false)
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                self?.scrollToBottom(animated: true)
                tableView.endUpdates()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
    func message(atIndex index: Int) -> Message {
        let messages = self.messages as! Results<Message>
        return messages[index]
    }

}
