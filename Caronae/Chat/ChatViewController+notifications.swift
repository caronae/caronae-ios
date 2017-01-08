extension ChatViewController {
    func clearNotifications() {
        NotificationService.instance.clearNotifications(forRideID: chat.ride.id, of: .chat)
    }
}
