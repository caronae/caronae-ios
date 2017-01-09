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
        notification.kind = .rideJoinRequest
        
        NotificationService.instance.createNotification(notification)
        ChatService.instance.subscribeToRide(withID: rideID)
        showMessageIfActive(message)
    }
    
    private func handleFinishedNotification(_ userInfo: [AnyHashable: Any]) {
        guard let (rideID, message) = rideNotificationInfo(userInfo) else {
            NSLog("Received ride finished notification but could not parse the notification data")
            return
        }
        
        NotificationService.instance.clearNotifications(forRideID: rideID)
        ChatService.instance.unsubscribeFromRide(withID: rideID)
        showMessageIfActive(message)
    }
    
    private func handleChatNotification(_ userInfo: [AnyHashable: Any]) {
        guard let (rideID, message) = rideNotificationInfo(userInfo),
            let _ = userInfo["senderId"] as? Int,
        let senderName = userInfo["senderName"] as? String else {
            return
        }
        
        // TODO: Trigger sync in ride messages
        
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
        showMessageIfActive(String(format: "%@: %@", senderName, message))
    }
    
    private func handleUnknownNotification(_ userInfo: [AnyHashable: Any]) {
        if let message = userInfo["message"] as? String {
            showMessageIfActive(message)
        } else {
            NSLog("Received unknown notification type: (%@)", userInfo)
        }
    }
    
    func showMessageIfActive(_ message: String) {
        if UIApplication.shared.applicationState == .active {
            CRToastManager.showNotification(options: [kCRToastTextKey: message], completionBlock: nil)
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
