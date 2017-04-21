import UIKit
import ActionSheetPicker_3_0

class FilterRideViewController: UIViewController, ZoneSelectionDelegate {
    @IBOutlet weak var neighborhoodButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    
    var selectedNeighborhoods: [String]? {
        didSet {
            let buttonTitle = selectedNeighborhoods?.compactString()
            self.neighborhoodButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    var selectedZone: String?
    var selectedHub: String?
    var hubs: [String]?
    let userDefaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hubs = ["Todos os Centros"]
        self.hubs?.append(contentsOf: CaronaeConstants.defaults().centers as! [String])
        
        // Load last filtered neighborhoods and center
        if let lastFilteredZone = self.userDefaults.string(forKey: CaronaePreferenceLastFilteredZoneKey),
           let lastFilteredNeighborhoods = self.userDefaults.array(forKey: CaronaePreferenceLastFilteredNeighborhoodsKey) as? [String],
           let lastFilteredCenter = self.userDefaults.string(forKey: CaronaePreferenceLastFilteredCenterKey) {
            self.selectedZone = lastFilteredZone
            self.selectedNeighborhoods = lastFilteredNeighborhoods
            self.selectedHub = lastFilteredCenter
        } else {
            self.selectedZone = ""
            self.selectedNeighborhoods = [CaronaeAllNeighborhoodsText]
            self.selectedHub = self.hubs?.first
        }
        
        self.centerButton.setTitle(self.selectedHub, for: .normal)
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
                                            CaronaePreferenceLastFilteredCenterKey: self.selectedHub!])
        
        self.performSegue(withIdentifier: "didTapFilterUnwind", sender: self)
    }
    
    @IBAction func selectCenterTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        let lastSearchedCenterIndex = self.hubs?.index(of: self.selectedHub!)
        
        ActionSheetStringPicker.show(withTitle: "Selecione um centro",
                                     rows: self.hubs,
                                     initialSelection: lastSearchedCenterIndex!,
                                     doneBlock: { picker, index, value in
                                        self.selectedHub = value as! String?
                                        self.centerButton.setTitle(value as! String?, for: .normal) },
                                     cancel: nil, origin: sender)
    }
    
    func hasSelectedNeighborhoods(_ neighborhoods: [Any]!, inZone zone: String!) {
        self.selectedZone = zone
        self.selectedNeighborhoods = neighborhoods as! [String]?
    }
    
    func isSearchValid() -> Bool {
        // Test if user has selected a neighborhood and/or hub
        if let neighborhood = selectedNeighborhoods?.first,
            neighborhood != CaronaeAllNeighborhoodsText || self.selectedHub != "Todos os Centros" {
            return true
        }
        return false
    }

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewZones" {
            let zoneSelectionVC = segue.destination as! ZoneSelectionViewController
            zoneSelectionVC.neighborhoodSelectionType = NeighborhoodSelectionMany
            zoneSelectionVC.delegate = self
        } else if segue.identifier == "didTapFilterUnwind" {
            let allRidesVC = segue.destination as! AllRidesViewController
            guard isSearchValid() else {
                allRidesVC.disableFilterRides()
                return
            }
            allRidesVC.enableFilterRides()
        }
    }

}
