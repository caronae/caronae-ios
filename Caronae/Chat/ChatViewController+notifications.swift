extension ChatViewController {
    func clearNotifications() {
        NotificationService.instance.clearNotifications(forRideID: ride.id, of: .chat)
    }
}
