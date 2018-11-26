import UIKit

class FilterRideViewController: UIViewController, NeighborhoodSelectionDelegate, HubSelectionDelegate {
    
    @IBOutlet weak var neighborhoodButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    
    var selectedNeighborhoods: [String]? {
        didSet {
            let buttonTitle = selectedNeighborhoods?.compactString()
            self.neighborhoodButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    var selectedCenters: [String]? {
        didSet {
            let buttonTitle = selectedCenters?.compactString()
            self.centerButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    var selectedZone: String?
    var selectedCampus: String?
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load last filtered neighborhoods and center
        if let lastFilteredZone = self.userDefaults.string(forKey: CaronaePreferenceLastFilter.zoneKey),
           let lastFilteredNeighborhoods = self.userDefaults.stringArray(forKey: CaronaePreferenceLastFilter.neighborhoodsKey),
           let lastFilteredCampus = self.userDefaults.string(forKey: CaronaePreferenceLastFilter.campusKey),
           let lastFilteredCenters = self.userDefaults.stringArray(forKey: CaronaePreferenceLastFilter.centersKey) {
            self.selectedZone = lastFilteredZone
            self.selectedNeighborhoods = lastFilteredNeighborhoods
            self.selectedCampus = lastFilteredCampus
            self.selectedCenters = lastFilteredCenters
        } else {
            self.selectedZone = ""
            self.selectedNeighborhoods = [CaronaeAllNeighborhoodsText]
            self.selectedCampus = ""
            self.selectedCenters = [CaronaeAllCampiText]
        }
    }
    
    
    // MARK: IBActions
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapFilterButton(_ sender: Any) {
        // Save filter parameters
        self.userDefaults.setValuesForKeys([CaronaePreferenceLastFilter.isEnabledKey: true,
                                            CaronaePreferenceLastFilter.zoneKey: self.selectedZone!,
                                            CaronaePreferenceLastFilter.neighborhoodsKey: self.selectedNeighborhoods!,
                                            CaronaePreferenceLastFilter.campusKey: self.selectedCampus!,
                                            CaronaePreferenceLastFilter.centersKey: self.selectedCenters!])
        
        self.performSegue(withIdentifier: "didTapFilterUnwind", sender: self)
    }
    
    @IBAction func selectCenterTapped(_ sender: Any) {
        let selectionVC = HubSelectionViewController(selectionType: .manySelection, hubTypeDirection: .centers)
        selectionVC.delegate = self
        self.navigationController?.show(selectionVC, sender: self)
    }
    
    @IBAction func selectNeighborhoodTapped(_ sender: Any) {
        let selectionVC = NeighborhoodSelectionViewController(selectionType: .manySelection)
        selectionVC.delegate = self
        self.navigationController?.show(selectionVC, sender: self)
    }
    
    
    // MARK: Selection Methods
    
    func hasSelected(hubs: [String], inCampus campus: String) {
        self.selectedCampus = campus
        self.selectedCenters = hubs
    }
    
    func hasSelected(neighborhoods: [String], inZone zone: String) {
        self.selectedZone = zone
        self.selectedNeighborhoods = neighborhoods
    }
    
    func isSearchValid() -> Bool {
        // Check if user has selected at least one neighborhood or center
        if self.selectedNeighborhoods! != [CaronaeAllNeighborhoodsText] || self.selectedCenters! != [CaronaeAllCampiText] {
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
