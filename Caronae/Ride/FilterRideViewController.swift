import UIKit

class FilterRideViewController: UIViewController, NeighborhoodSelectionDelegate, HubSelectionDelegate {
    
    @IBOutlet weak var neighborhoodButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    
    var selectedNeighborhoods: [String]? {
        didSet {
            var buttonTitle = selectedNeighborhoods?.compactString()
            if buttonTitle == "Outra" {
                buttonTitle = "Outros"
            }
            self.neighborhoodButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    var selectedHubs: [String]? {
        didSet {
            let buttonTitle = selectedHubs?.compactString()
            self.centerButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    var selectedZone: String?
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load last filtered neighborhoods and center
        if let lastFilteredZone = self.userDefaults.string(forKey: CaronaePreferenceLastFilteredZoneKey),
           let lastFilteredNeighborhoods = self.userDefaults.stringArray(forKey: CaronaePreferenceLastFilteredNeighborhoodsKey),
           let lastFilteredCenters = self.userDefaults.stringArray(forKey: CaronaePreferenceLastFilteredCentersKey) {
            self.selectedZone = lastFilteredZone
            self.selectedNeighborhoods = lastFilteredNeighborhoods
            self.selectedHubs = lastFilteredCenters
        } else {
            self.selectedZone = ""
            self.selectedNeighborhoods = [CaronaeAllNeighborhoodsText]
            self.selectedHubs = [CaronaeAllHubsText]
        }
    }
    
    
    // MARK: IBActions
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapFilterButton(_ sender: Any) {
        // Save filter parameters
        self.userDefaults.setValuesForKeys([CaronaePreferenceFilterIsEnabledKey: true,
                                            CaronaePreferenceLastFilteredZoneKey: self.selectedZone!,
                                            CaronaePreferenceLastFilteredNeighborhoodsKey: self.selectedNeighborhoods!,
                                            CaronaePreferenceLastFilteredCentersKey: self.selectedHubs!])
        
        self.performSegue(withIdentifier: "didTapFilterUnwind", sender: self)
    }
    
    @IBAction func selectCenterTapped(_ sender: Any) {
        let selectionVC = HubSelectionViewController.makeVC(selectionType: .manySelection, hubTypeDirection: .centers)
        selectionVC.delegate = self
        self.navigationController?.show(selectionVC, sender: self)
    }
    
    @IBAction func selectNeighborhoodTapped(_ sender: Any) {
        let selectionVC = NeighborhoodSelectionViewController.makeVC(selectionType: .manySelection)
        selectionVC.delegate = self
        self.navigationController?.show(selectionVC, sender: self)
    }
    
    
    // MARK: Selection Methods
    
    func hasSelected(hubs: [String]) {
        self.selectedHubs = hubs
    }
    
    func hasSelected(neighborhoods: [String], inZone zone: String) {
        self.selectedZone = zone
        self.selectedNeighborhoods = neighborhoods
    }
    
    func isSearchValid() -> Bool {
        // Test if user has selected a neighborhood and/or hub
        if self.selectedNeighborhoods! != [CaronaeAllNeighborhoodsText] || self.selectedHubs! != [CaronaeAllHubsText] {
            return true
        }
        return false
    }

    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "didTapFilterUnwind" {
            let allRidesVC = segue.destination as! AllRidesViewController
            guard isSearchValid() else {
                allRidesVC.disableFilterRides()
                return
            }
            allRidesVC.enableFilterRides()
        }
    }

}
