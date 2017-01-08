import CRToast

extension AppDelegate {
    func updateApplicationBadgeNumber() {
        guard let notifications = try? NotificationService.instance.getNotifications() else { return }
        UIApplication.shared.applicationIconBadgeNumber = notifications.count
    }
    
    func handleJoinRequestNotification(_ userInfo: [String: Any]) {
        guard let rideID = userInfo["rideId"] as? Int,
            let message = userInfo["message"] as? String else { return }
        
        let notification = Notification()
        notification.rideID = rideID
        notification.kind = .rideJoinRequest
        
        NotificationService.instance.createNotification(notification)
        showMessageIfActive(message)
    }
    
    func handleFinishedNotification(_ userInfo: [String: Any]) {
        guard let rideID = userInfo["rideId"] as? Int,
            let message = userInfo["message"] as? String else { return }
        
        NotificationService.instance.clearNotifications(forRideID: rideID)
        showMessageIfActive(message)
    }
    
    func handleChatNotification(_ userInfo: [String: Any]) {
        guard let _ = userInfo["senderId"] as? Int,
        let rideID = userInfo["rideId"] as? Int,
        let senderName = userInfo["senderName"] as? String,
        let body = userInfo["message"] as? String else {
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
        showMessageIfActive(String(format: "%@: %@", senderName, body))
    }
    
    func showMessageIfActive(_ message: String) {
        if UIApplication.shared.applicationState == .active {
            CRToastManager.showNotification(options: [kCRToastTextKey: message], completionBlock: nil)
        }
    }
}
