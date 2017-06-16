import UIKit
import RealmSwift

class MyRidesViewController: RideListController {
    var ridesNotificationToken: NotificationToken? = nil
    var unreadNotifications: Results<Notification>!
    
    var sectionRides = [Results<Ride>]()
    let sectionTitles = ["Pendentes", "Ativas", "Ofertadas"]
    
    override func viewDidLoad() {
        hidesDirectionControl = true
        super.viewDidLoad()
        
        self.navigationController?.view.backgroundColor = UIColor.white
        navigationItem.titleView = UIImageView(image: UIImage(named: "NavigationBarLogo"))
        
        changeBackgroundIfNeeded()
        
        RideService.instance.getMyRides(success: { pending, active, offered in
            self.sectionRides = [pending, active, offered]
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
        RideService.instance.updateMyRides(success: {
            self.refreshControl.endRefreshing()
            NSLog("My rides updated")
        }, error: { error in
            self.refreshControl.endRefreshing()
            NSLog("Error updating my rides (\(error.localizedDescription))")
        })
    }
    
    func subscribeToChanges() {
        let pending = sectionRides[0]
        let active  = sectionRides[1]
        let offered = sectionRides[2]
        
        ridesNotificationToken = pending.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            self?.handleChanges(changes, inSection: 0)
        }
        
        ridesNotificationToken = active.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            self?.handleChanges(changes, inSection: 1)
        }
        
        ridesNotificationToken = offered.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            self?.handleChanges(changes, inSection: 2)
        }
    }
    
    func handleChanges(_ changes: RealmCollectionChange<Results<Ride>>, inSection section: Int) {
        guard let tableView = self.tableView else { return }
        
        switch changes {
        case .initial:
            // Results are now populated and can be accessed without blocking the UI
            tableView.reloadData()
            break
        case .update(_, let deletions, let insertions, let modifications):
            // Query results have changed, so apply them to the UITableView
            tableView.beginUpdates()
            tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: section) }),
                                 with: .automatic)
            tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: section)}),
                                 with: .automatic)
            tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: section) }),
                                 with: .automatic)
            tableView.endUpdates()

            if emptyBackgroundIsVisible() {
                // Workaround to display tableview correctly when leaving the emptyBackground
                changeBackgroundIfNeeded()
                tableView.reloadData()
            }
            changeBackgroundIfNeeded()
            break
        case .error(let error):
            // An error occurred while opening the Realm file on the background worker thread
            fatalError("\(error)")
            break
        }
    }
    
    func updateNotificationBadges() {
        unreadNotifications = try! NotificationService.instance.getNotifications(of: [.chat, .rideJoinRequest, .rideJoinRequestAccepted])
        if unreadNotifications.isEmpty {
            navigationController?.tabBarItem.badgeValue = nil
        } else {
            navigationController?.tabBarItem.badgeValue = String(format: "%ld", unreadNotifications.count)
        }
        tableView.reloadData()
    }
    
    func changeBackgroundIfNeeded() {
        tableView.backgroundView = (sectionRides.contains(where: { !$0.isEmpty })) ? nil : emptyTableLabel
    }
    
    func emptyBackgroundIsVisible() -> Bool {
        return (tableView.backgroundView != nil) ? true : false
    }
    
    func openChatForRide(withID rideID: Int) {
        var ride: Ride
        if let realmRide = RideService.instance.getRideFromRealm(withID: rideID) {
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        guard !emptyBackgroundIsVisible() else {
            return nil
        }
        
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard sectionRides[section].isEmpty || sectionTitles[section] == "Ativas" else {
            return nil
        }
        
        var label = String()
        
        if sectionRides[section].isEmpty {
            switch(sectionTitles[section]) {
            case "Pendentes" : label = "Você não possui nenhuma carona Pendente. \nVocê pode requisitar novas caronas na seção 'Todas'."
            case "Ativas"    : label = "Você não possui nenhuma carona Ativa. \nCaronas são ativas quando existem caronistas."
            case "Ofertadas" : label = "Você não possui nenhuma carona Ofertada. \nVocê pode ofertar novas caronas através do botão '+'."
            default: break
            }
        } else {
            label = "Se você é motorista de alguma carona, não\n esqueça de concluí-la após seu término. :)"
        }
        
        let tableFooter = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        tableFooter.text = label
        tableFooter.numberOfLines = 0
        tableFooter.backgroundColor = .white
        tableFooter.font = .systemFont(ofSize: 10)
        tableFooter.textColor = .lightGray
        tableFooter.textAlignment = .center
        return tableFooter
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard !emptyBackgroundIsVisible() && (sectionRides[section].isEmpty || sectionTitles[section] == "Ativas") else {
            return 0.0
        }
        
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionRides[section].count
    }
    
    override func tableView(_ tableView: UITableView!, cellForRowAt indexPath: IndexPath!) -> RideCell! {
        let ride = sectionRides[indexPath.section][indexPath.row]
        
        let cell = tableView?.dequeueReusableCell(withIdentifier: "Ride Cell", for: indexPath) as! RideCell
        cell.configureCell(with: ride)
        cell.badgeCount = unreadNotifications.filter{ $0.rideID == ride.id }.count
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView!, didSelectRowAt indexPath: IndexPath!) {
        tableView?.deselectRow(at: indexPath, animated: true)
        
        let ride = sectionRides[indexPath.section][indexPath.row]
        if let rideVC = RideViewController(for: ride) {
            self.navigationController?.show(rideVC, sender: self)
        }
    }
    
}
