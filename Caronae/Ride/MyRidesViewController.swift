//
//  MyRidesViewController.swift
//  Caronae
//
//  Created by Mario Cecchi on 04/01/2017.
//  Copyright © 2017 Mario Cecchi. All rights reserved.
//

import UIKit
import RealmSwift

class MyRidesViewController: RideListController {
    
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        hidesDirectionControl = true
        super.viewDidLoad()
        
        RideService.instance.getOfferedRides(success: { rides in
            self.rides = rides
            self.tableView.backgroundView = nil
            self.listenToChanges()
        }, error: { error in
            
        })
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
    
    func listenToChanges() {
        // Observe Results Notifications
        guard let rides = rides as? Results<Ride> else {
            return
        }
        
        notificationToken = rides.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
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
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
