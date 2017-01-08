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
    
    func showMessageIfActive(_ message: String) {
        if UIApplication.shared.applicationState == .active {
            CRToastManager.showNotification(options: [kCRToastTextKey: message], completionBlock: nil)
        }
    }
}
