import CRToast
import AudioToolbox

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
        case "canceled", "cancelled", "finished", "refused":
            handleFinishedNotification(userInfo)
        case "quitter":
            handleQuitterNotification(userInfo)
        default:
            handleUnknownNotification(userInfo)
            return false
        }
        
        return true
    }
    
    private func handleJoinRequestNotification(_ userInfo: [AnyHashable: Any]) {
        guard let (id, senderID, rideID, message) = rideNotificationInfo(userInfo) else {
            NSLog("Received ride join request notification but could not parse the notification data")
            return
        }
        
        let notification = Notification()
        notification.id = id
        notification.senderID = senderID
        notification.rideID = rideID
        notification.kind = .rideJoinRequest
        
        NotificationService.instance.createNotification(notification)
        showMessageIfActive(message)
    }
    
    private func handleJoinRequestAccepted(_ userInfo: [AnyHashable: Any]) {
        guard let (id, senderID, rideID, message) = rideNotificationInfo(userInfo) else {
            NSLog("Received ride join request accepted notification but could not parse the notification data")
            return
        }
        
        let notification = Notification()
        notification.id = id
        notification.senderID = senderID
        notification.rideID = rideID
        notification.kind = .rideJoinRequestAccepted
        
        NotificationService.instance.createNotification(notification)
        updateMyRidesIfActive()
        showMessageIfActive(message)
    }
    
    private func handleFinishedNotification(_ userInfo: [AnyHashable: Any]) {
        guard let (_, _, rideID, message) = rideNotificationInfo(userInfo) else {
            NSLog("Received ride finished notification but could not parse the notification data")
            return
        }
        
        NotificationService.instance.clearNotifications(forRideID: rideID)
        updateMyRidesIfActive()
        showMessageIfActive(message)
    }
    
    private func handleQuitterNotification(_ userInfo: [AnyHashable: Any]) {
        guard let (_, _, _, message) = rideNotificationInfo(userInfo) else {
            NSLog("Received quitter notification but could not parse the notification data")
            return
        }
        
        updateMyRidesIfActive()
        showMessageIfActive(message)
    }
    
    private func handleChatNotification(_ userInfo: [AnyHashable: Any]) {
        guard let (id, senderID, rideID, message) = rideNotificationInfo(userInfo),
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
        notification.id = id
        notification.senderID = senderID
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
        AudioServicesPlayAlertSound(beepSound)
    }
    
    func showMessageIfActive(_ message: String) {
        if UIApplication.shared.applicationState == .active {
            playNotificationSound()
            CRToastManager.showNotification(options: [kCRToastTextKey: message], completionBlock: nil)
        }
    }
    
    func updateMyRidesIfActive() {
        if UIApplication.shared.applicationState == .active {
            RideService.instance.updateMyRides(success: {
                NSLog("My rides updated")
            }, error: { error in
                NSLog("Error updating my rides (\(error.localizedDescription))")
            })
        }
    }
    
    @objc func updateApplicationBadgeNumber() {
        guard let notifications = try? NotificationService.instance.getNotifications() else { return }
        UIApplication.shared.applicationIconBadgeNumber = notifications.count
    }
    
    private func rideNotificationInfo(_ userInfo: [AnyHashable: Any]) -> (String, Int, Int, String)? {
        guard let id = userInfo["id"] as? String,
            let senderIDString = userInfo["senderId"] as? String,
            let senderID = Int(senderIDString),
            let rideIDString = userInfo["rideId"] as? String,
            let rideID = Int(rideIDString),
            let message = userInfo["message"] as? String else {
                return nil
        }
        
        return (id, senderID, rideID, message)
    }
}
