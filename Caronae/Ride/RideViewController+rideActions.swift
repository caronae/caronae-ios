import SVProgressHUD
import Sheriff

extension RideViewController {
    
    func userIsRider() -> Bool {
        let userID = UserService.instance.user!.id
        guard ride.riders.contains(where: { $0.id == userID }) else {
            return false
        }
        
        return true
    }
    
    func userIsDriver() -> Bool {
        return UserService.instance.user!.id == ride.driver.id
    }
    
    @objc func updateChatButtonBadge() {
        guard let unreadNotifications = try? NotificationService.instance.getNotifications(of: [.chat])
            .filter({ $0.rideID == self.ride.id }) else { return }

        let badge = GIBadgeView()
        let button = UIButton()
        
        button.setTitle("Chat  ", for: .normal)
        button.setTitleColor(navigationController?.navigationBar.tintColor, for: .normal)
        button.addTarget(self, action: #selector(openChatWindow), for: .touchUpInside)
        button.titleLabel?.addSubview(badge)
        badge.badgeValue = unreadNotifications.count
        
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton
    }
    
    func deleteRoutine() {
        let routineID = self.ride.routineID.value!
        NSLog("Requesting to delete routine with id %ld", routineID)
        
        cancelButton.isEnabled = false
        SVProgressHUD.show()
        
        RideService.instance.deleteRoutine(withID: routineID, success: { 
            SVProgressHUD.dismiss()
            NSLog("User left all rides from routine.")
            lastAllRidesUpdate = Date.distantPast
            _ = self.navigationController?.popViewController(animated: true)
        }, error: { error in
            SVProgressHUD.dismiss()
            self.cancelButton.isEnabled = true
            NSLog("Error deleting routine (%@)", error.localizedDescription)
            
            CaronaeAlertController.presentOkAlert(withTitle: "Algo deu errado.",
                                                  message: String(format: "Não foi possível cancelar sua rotina. (%@)", error.localizedDescription))
        })
    }
    
    func clearNotifications() {
        NotificationService.instance.clearNotifications(forRideID: ride.id, of: [.rideJoinRequestAccepted])
    }
    
    func clearNotificationOfJoinRequest(from senderID: Int) {
        NotificationService.instance.clearNotifications(forRideID: ride.id, of: [.rideJoinRequest], from: senderID)
    }
    
    func loadRealmRide() {
        if let realmRide = RideService.instance.getRideFromRealm(withID: self.ride.id) {
            NSLog("Ride loaded from realm database")
            self.ride = realmRide
        }
    }
}
