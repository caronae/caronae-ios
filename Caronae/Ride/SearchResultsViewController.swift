import UIKit
import SVProgressHUD

class SearchResultsViewController: RideListController, SearchRideDelegate {
    
    var previouslySelectedSegmentIndex = 0
    
    override func viewDidLoad() {
        hidesDirectionControl = true
        super.viewDidLoad()
    }
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchRide" {
            let searchNavController = segue.destination as! UINavigationController
            let searchVC = searchNavController.viewControllers.first as! SearchRideViewController
            searchVC.previouslySelectedSegmentIndex = previouslySelectedSegmentIndex
            searchVC.delegate = self
        }
    }
    
    @IBAction func showResultsUnwind(_ segue: UIStoryboardSegue) {
    }
    
    
    // MARK: Search methods
    
    func searchedForRide(withParameters parameters: FilterParameters) {
        SVProgressHUD.show()
        if tableView.backgroundView != nil {
            tableView.backgroundView = loadingLabel
        }
        
        RideService.instance.getRides(page: 1, filterParameters: parameters, success: { rides, lastPage in
            self.rides = rides
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
            
            if rides.isEmpty {
                // Hack so that the alert is not presented from the modal search dialog
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    CaronaeAlertController.presentOkAlert(withTitle: "Nenhuma carona\nencontrada :(", message: "Você pode ampliar sua pesquisa selecionando vários bairros ou escolhendo um horário mais cedo.")
                })
            }
        }, error: { error in
            SVProgressHUD.dismiss()
            self.loadingFailed(withError: error as NSError)
        })
    }

}
