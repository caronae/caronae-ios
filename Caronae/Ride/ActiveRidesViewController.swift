import UIKit
import RealmSwift

class ActiveRidesViewController: RideListController {
    var ridesNotificationToken: NotificationToken? = nil
    var unreadNotifications: Results<Notification>!
    
    override func viewDidLoad() {
        hidesDirectionControl = true
        super.viewDidLoad()
        
        self.navigationController?.view.backgroundColor = UIColor.white
        navigationItem.titleView = UIImageView(image: UIImage(named: "NavigationBarLogo"))
        
        self.tableView.tableFooterView = tableFooter
        
        RideService.instance.getActiveRides(success: { rides in
            self.rides = rides
            self.subscribeToChanges()
        }, error: { error in
            self.loadingFailedWithError(error)
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationBadges), name: Foundation.Notification.Name.CaronaeDidUpdateNotifications, object: nil)
        updateNotificationBadges()
    }
    
    deinit {
        ridesNotificationToken?.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    func refreshTable() {
        RideService.instance.updateActiveRides(success: {
            self.refreshControl.endRefreshing()
            NSLog("Active rides updated")
        }, error: { error in
            self.refreshControl.endRefreshing()
            NSLog("Error updating active rides (\(error.localizedDescription))")
        })
    }
    
    func subscribeToChanges() {
        guard let rides = rides as? Results<Ride> else {
            return
        }
        
        ridesNotificationToken = rides.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            self?.updateFilteredRides()
            
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
    func updateNotificationBadges() {
        unreadNotifications = try! NotificationService.instance.getNotifications(of: [.chat, .rideJoinRequestAccepted])
        if unreadNotifications.isEmpty {
            navigationController?.tabBarItem.badgeValue = nil
        } else {
            navigationController?.tabBarItem.badgeValue = String(format: "%ld", unreadNotifications.count)
        }
        tableView.reloadData()
    }
    
    func openChatForRide(withID rideID: Int) {
        let realm = try! Realm()
        var ride: Ride
        
        if let realmRide = realm.objects(Ride.self).filter("id == %@", rideID).first {
            ride = realmRide
        } else {
            let rides = self.rides as? [Ride]
            guard let rideFiltered = rides?.filter({ $0.id == rideID }).first else {
                return
            }
            ride = rideFiltered
        }
        
        let rideViewController = RideViewController(for: ride)!
        rideViewController.shouldOpenChatWindow = true
        _ = navigationController?.popToRootViewController(animated: false)
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
