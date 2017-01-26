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
            self.tableView.reloadData()
            self.tableView.tableFooterView = rides.isEmpty ? nil : self.tableFooter
        }, error: { error in
            self.refreshControl.endRefreshing()
            self.loadingFailedWithError(error)
            self.tableView.reloadData()
            self.tableView.tableFooterView = nil
        })
    }
    
    func refreshTable(_ sender: Any) {
        loadRides()
    }
    
    func updateNotificationBadges() {
        unreadNotifications = try! NotificationService.instance.getNotifications(of: [.chat, .rideJoinRequestAccepted])
        if unreadNotifications.isEmpty {
            navigationController?.tabBarItem.badgeValue = nil
        } else {
            navigationController?.tabBarItem.badgeValue = String(format: "%ld", unreadNotifications.count)
        }
        loadRides()
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
        let ride = filteredRides[indexPath.row]

        let cell = super.tableView(tableView, cellForRowAt: indexPath)!
        cell.badgeCount = unreadNotifications.filter{ $0.rideID == ride.id }.count

        return cell
    }
    
    lazy var tableFooter: UIView = {
        let tableFooter = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        tableFooter.text = "Se você é motorista de alguma carona, não\n esqueça de concluí-la após seu término. :)"
        tableFooter.numberOfLines = 0
        tableFooter.backgroundColor = .white
        tableFooter.font = .systemFont(ofSize: 10)
        tableFooter.textColor = .lightGray
        tableFooter.textAlignment = .center
        return tableFooter
    }()
    
}
