import UIKit

class RidesHistoryViewController: RideListController {

    override func viewDidLoad() {
        hidesDirectionControl = true
        super.viewDidLoad()
        
        loadRidesHistory()
    }

    override func refreshTable() {
        loadRidesHistory()
    }
    
    
    // MARK: Rides methods
    
    func loadRidesHistory() {
        if tableView.backgroundView != nil {
            tableView.backgroundView = loadingLabel
        }
        
        UserService.instance.getUserRidesHistory(success: { rides in
            self.rides = rides
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }, error: { error in
            self.refreshControl?.endRefreshing()
            self.loadingFailed(withError: error as NSError)
        })
    }
}
