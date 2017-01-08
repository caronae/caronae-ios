import UIKit
import RealmSwift

class ActiveRidesViewController: RideListController {
    var unreadNotifications: Results<Notification>!
    
    override func viewDidLoad() {
        hidesDirectionControl = true
        super.viewDidLoad()
        
        self.navigationController?.view.backgroundColor = UIColor.white
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "NavigationBarLogo"))
        
        loadRides()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationBadges), name: Foundation.Notification.Name.CaronaeDidUpdateNotifications, object: nil)
        updateNotificationBadges()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadRides() {
        RideService.instance.getActiveRides(success: { rides in
            self.refreshControl.endRefreshing()
            self.rides = rides
        }, error: { error in
            self.refreshControl.endRefreshing()
            self.loadingFailedWithError(error)
        })
    }
    
    func refreshTable(_ sender: Any) {
        loadRides()
    }
    
    func updateNotificationBadges() {
        unreadNotifications = try! NotificationService.instance.getNotifications(of: .chat)
        if unreadNotifications.isEmpty {
            navigationController?.tabBarItem.badgeValue = nil
        } else {
            navigationController?.tabBarItem.badgeValue = String(format: "%ld", unreadNotifications.count)
        }
        tableView.reloadData()
    }
    
    func openChatForRide(withID rideID: Int) {
        var rides = self.rides as! [Ride]
        rides = rides.filter { $0.id == rideID }
        guard let ride = rides.first else {
            return
        }
        
        let rideViewController = RideViewController(for: ride)!
        rideViewController.shouldOpenChatWindow = true
        navigationController?.pushViewController(rideViewController, animated: true)
    }
    
    // MARK: Table methods
    
    override func tableView(_ tableView: UITableView!, cellForRowAt indexPath: IndexPath!) -> RideCell! {
        var unreadCount = 0
        let ride = filteredRides[indexPath.row]
        
        for notification in unreadNotifications {
            if notification.rideID == ride.id {
                unreadCount += 1
            }
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)!
        
        cell.badgeCount = unreadCount
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let titleMessage = UILabel()
        titleMessage.text = "Se você é motorista de alguma carona, não\n esqueça de concluí-la após seu término. :)"
        titleMessage.numberOfLines = 0
        titleMessage.backgroundColor = .white
        titleMessage.font = .systemFont(ofSize: 10)
        titleMessage.textColor = .lightGray
        titleMessage.textAlignment = .center
        return titleMessage
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
        
        
    }
    
    
}
