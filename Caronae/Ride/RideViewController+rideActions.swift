import RealmSwift
import SVProgressHUD
import MIBadgeButton_Swift

extension RideViewController {
    var riders: Any? {
        return ride.riders
    }
    
    // Method only to get around the issue that Realm's List<User> is not available on Objective-C
    func rider(atIndex index: Int) -> User {
        return ride.riders[index]
    }
    
    func userIsRider() -> Bool {
        let userID = UserService.instance.user!.id
        for rider in ride.riders {
            if rider.id == userID {
                return true
            }
        }
        return false
    }
    
    func userIsDriver() -> Bool {
        return UserService.instance.user!.id == ride.driver.id
    }
    
    func updateChatButtonBadge() {
        guard let unreadNotifications = try? NotificationService.instance.getNotifications(of: [.chat])
            .filter({ $0.rideID == self.ride.id }) else { return }
        
        let button = MIBadgeButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        button.setTitle("Chat", for: .normal)
        button.setTitleColor(navigationController?.navigationBar.tintColor, for: .normal)
        button.addTarget(self, action: #selector(openChatWindow), for: .touchUpInside)
        button.badgeString = unreadNotifications.isEmpty ? nil : String(unreadNotifications.count)
        
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
            
            _ = self.navigationController?.popViewController(animated: true)
        }, error: { error in
            SVProgressHUD.dismiss()
            self.cancelButton.isEnabled = true
            NSLog("Error deleting routine (%@)", error.localizedDescription)
            
            CaronaeAlertController.presentOkAlert(withTitle: "Algo deu errado.", message: String(format: "Não foi possível cancelar sua rotina. (%@)", error.localizedDescription))
        })
    }
    
    func clearNotifications() {
        NotificationService.instance.clearNotifications(forRideID: ride.id, of: .rideJoinRequestAccepted)
    }
    
    func subscribeToChanges() {
        ridersNotificationToken = ride.riders.addNotificationBlock { (changes: RealmCollectionChange) in
            
            if (self.userIsDriver() && self.finishRideViewHeightZero.isActive && self.ride.isActive) {
                self.finishRideViewHeightZero.isActive = false
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
            }
            
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.ridersCollectionView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UICollectionView
                self.ridersCollectionView.performBatchUpdates({
                    self.ridersCollectionView.insertItems(at: insertions.map{ IndexPath(row: $0, section: 0) })
                    self.ridersCollectionView.deleteItems(at: deletions.map{ IndexPath(row: $0, section: 0) })
                    self.ridersCollectionView.reloadItems(at: modifications.map{ IndexPath(row: $0, section: 0) })
                }, completion: { _ in })
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
}

