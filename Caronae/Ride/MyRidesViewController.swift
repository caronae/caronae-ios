import UIKit
import RealmSwift

class MyRidesViewController: RideListController {
    var ridesNotificationToken: NotificationToken? = nil
    var unreadNotifications: [Any] = []
    
    override func viewDidLoad() {
        hidesDirectionControl = true
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "NavigationBarLogo"))
        
        RideService.instance.getOfferedRides(success: { rides in
            self.rides = rides
            self.tableView.backgroundView = nil
            self.subscribeToChanges()
        }, error: { error in
            self.tableView.backgroundView = self.errorLabel
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationBadges), name: Notification.Name.CaronaeDidUpdateNotifications, object: nil)
        updateNotificationBadges()
    }
    
    deinit {
        ridesNotificationToken?.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    func refreshTable(_ sender: Any) {
        RideService.instance.updateOfferedRides(success: { _ in
            self.refreshControl.endRefreshing()
            NSLog("Offered rides updated")
        }, error: { error in
            self.refreshControl.endRefreshing()
            NSLog("Error updating offered rides (\(error?.localizedDescription))")
        })
    }
    
    func subscribeToChanges() {
        guard let rides = rides as? Results<Ride> else {
            return
        }
        
        ridesNotificationToken = rides.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
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
            
            tableView.backgroundView = rides.isEmpty ? self?.emptyTableLabel : nil
        }
    }
    
    func updateNotificationBadges() {
        unreadNotifications = NotificationStore.getNotificationsOf(NotificationTypeRequest)
        if unreadNotifications.isEmpty {
            navigationController?.tabBarItem.badgeValue = nil
        } else {
            navigationController?.tabBarItem.badgeValue = String(format: "%ld", unreadNotifications.count)
        }
        tableView.reloadData()
    }

    // MARK: Table methods
    
    // TODO: Add badges to cells with notifications
}
