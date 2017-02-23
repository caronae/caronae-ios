import CRToast

extension AppDelegate {
    func handleNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard let notificationType = userInfo["msgType"] as? String else {
            handleUnknownNotification(userInfo)
            return false
        }
        
        switch notificationType {
        case "chat":
            handleChatNotification(userInfo)
        case "joinRequest":
            handleJoinRequestNotification(userInfo)
        case "accepted":
            handleJoinRequestAccepted(userInfo)
        case "canceled", "cancelled", "finished":
            handleFinishedNotification(userInfo)
        default:
            handleUnknownNotification(userInfo)
            return false
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.CaronaeNotificationReceived, object: self)
        
        return true
    }
    
    private func handleJoinRequestNotification(_ userInfo: [AnyHashable: Any]) {
        guard let (rideID, message) = rideNotificationInfo(userInfo) else {
            NSLog("Received ride join request notification but could not parse the notification data")
            return
        }
        
        let notification = Notification()
        notification.rideID = rideID
        notification.kind = .rideJoinRequest
        
        NotificationService.instance.createNotification(notification)
        showMessageIfActive(message)
    }
    
    private func handleJoinRequestAccepted(_ userInfo: [AnyHashable: Any]) {
        guard let (rideID, message) = rideNotificationInfo(userInfo) else {
            NSLog("Received ride join request accepted notification but could not parse the notification data")
            return
        }
        
        let notification = Notification()
        notification.rideID = rideID
        notification.kind = .rideJoinRequestAccepted
        
        NotificationService.instance.createNotification(notification)
        updateActiveRidesIfActive()
        showMessageIfActive(message)
    }
    
    private func handleFinishedNotification(_ userInfo: [AnyHashable: Any]) {
        guard let (rideID, message) = rideNotificationInfo(userInfo) else {
            NSLog("Received ride finished notification but could not parse the notification data")
            return
        }
        
        NotificationService.instance.clearNotifications(forRideID: rideID)
        updateActiveRidesIfActive()
        showMessageIfActive(message)
    }
    
    private func handleChatNotification(_ userInfo: [AnyHashable: Any]) {
        guard let (rideID, message) = rideNotificationInfo(userInfo),
            let senderIDString = userInfo["senderId"] as? String,
            let senderID = Int(senderIDString),
            senderID != UserService.instance.user?.id else {
                return
        }
        
        ChatService.instance.updateMessagesForRide(withID: rideID) { error in
            guard error == nil else {
                NSLog("Error updating messages for ride %ld. (%@)", rideID, error!.localizedDescription)
                return
            }
            
            NSLog("Updated messages for ride %ld", rideID)
        }
        
        // Display notification if the chat window is not already open
        
        let notification = Notification()
        notification.kind = .chat
        notification.rideID = rideID
        
        if UIApplication.shared.applicationState != .active {
            NotificationService.instance.createNotification(notification)
            return
        }
        
        if let topViewController = UIApplication.shared.topViewController(),
            let chatViewController = topViewController as? ChatViewController,
            chatViewController.ride.id == rideID {
            return
        }
            
        NotificationService.instance.createNotification(notification)
        showMessageIfActive(message)
    }
    
    private func handleUnknownNotification(_ userInfo: [AnyHashable: Any]) {
        if let message = userInfo["message"] as? String {
            showMessageIfActive(message)
        } else {
            NSLog("Received unknown notification type: (%@)", userInfo)
        }
    }
    
    func playNotificationSound() {
        guard let url = Bundle.main.url(forResource: "beep", withExtension: "wav") else {
            NSLog("Notification sound not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer.play()
        } catch let error {
            NSLog("Error: %@", error.localizedDescription)
        }
    }
    
    func showMessageIfActive(_ message: String) {
        if UIApplication.shared.applicationState == .active {
            playNotificationSound()
            CRToastManager.showNotification(options: [kCRToastTextKey: message], completionBlock: nil)
        }
    }
    
    func updateActiveRidesIfActive () {
        if UIApplication.shared.applicationState == .active {
            RideService.instance.updateActiveRides(success: {
                NSLog("Active rides updated")
            }, error: { error in
                NSLog("Error updating active rides (\(error.localizedDescription))")
            })
        }
    }
    
    func updateApplicationBadgeNumber() {
        guard let notifications = try? NotificationService.instance.getNotifications() else { return }
        UIApplication.shared.applicationIconBadgeNumber = notifications.count
    }
    
    private func rideNotificationInfo(_ userInfo: [AnyHashable: Any]) -> (Int, String)? {
        guard let rideIDString = userInfo["rideId"] as? String,
            let rideID = Int(rideIDString),
            let message = userInfo["message"] as? String else {
                return nil
        }
        
        return (rideID, message)
    }
}
