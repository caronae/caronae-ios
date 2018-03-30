import UIKit
import ActionSheetPicker_3_0

protocol SearchRideDelegate: class {
    func searchedForRide(withParameters parameters: FilterParameters)
}

class SearchRideViewController: UIViewController, NeighborhoodSelectionDelegate, HubSelectionDelegate {

    weak var delegate: SearchRideDelegate?
    
    @IBOutlet weak var directionControl: UISegmentedControl!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var neighborhoodButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    
    var selectedNeighborhoods: [String]? {
        didSet {
            var buttonTitle = selectedNeighborhoods?.compactString()
            if buttonTitle == CaronaeOtherZoneText {
                buttonTitle = CaronaeOtherNeighborhoodsText
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
    var selectedCampus: String?
    var selectedDate: Date? {
        didSet {
            let dateString = dateFormatter.string(from: selectedDate!)
            dateButton.setTitle(dateString, for: .normal)
        }
    }
    let userDefaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    
    var previouslySelectedSegmentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = CaronaeSearchDateFormat
        
        // Configure direction titles according to institution
        directionControl.setTitle(PlaceService.Institution.goingLabel, forSegmentAt: 0)
        directionControl.setTitle(PlaceService.Institution.leavingLabel, forSegmentAt: 1)
        
        // Load last direction
        directionControl.selectedSegmentIndex = previouslySelectedSegmentIndex
        
        // Load last searched zone, neighborhoods, campus and centers
        if let lastSearchedZone = self.userDefaults.string(forKey: CaronaePreferenceLastSearch.zoneKey),
            let lastSearchedNeighborhoods = self.userDefaults.stringArray(forKey: CaronaePreferenceLastSearch.neighborhoodsKey),
            let lastSearchedCampus = self.userDefaults.string(forKey: CaronaePreferenceLastSearch.campusKey),
            let lastSearchedCenters = self.userDefaults.stringArray(forKey: CaronaePreferenceLastSearch.centersKey) {
            selectedZone = lastSearchedZone
            selectedNeighborhoods = lastSearchedNeighborhoods
            selectedCampus = lastSearchedCampus
            selectedHubs = lastSearchedCenters
        } else {
            selectedZone = ""
            selectedNeighborhoods = [CaronaeAllNeighborhoodsText]
            selectedCampus = ""
            selectedHubs = [CaronaeAllCampiText]
        }
        
        // Load last searched date
        if let lastSearchedDate = self.userDefaults.object(forKey: CaronaePreferenceLastSearch.dateKey) as? Date, lastSearchedDate.isInTheFuture() {
            selectedDate = lastSearchedDate
        } else {
            selectedDate = Date.nextHour
        }
    }
    
    
    // MARK: IBActions
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSearchButton(_ sender: Any) {
        // Save search parameters for the next search
        self.userDefaults.setValuesForKeys([CaronaePreferenceLastSearch.zoneKey: self.selectedZone!,
                                            CaronaePreferenceLastSearch.neighborhoodsKey: self.selectedNeighborhoods!,
                                            CaronaePreferenceLastSearch.campusKey: self.selectedCampus!,
                                            CaronaePreferenceLastSearch.centersKey: self.selectedHubs!,
                                            CaronaePreferenceLastSearch.dateKey: self.selectedDate!])
        
        let going = (self.directionControl.selectedSegmentIndex == 0)
        
        let searchParams = FilterParameters(going: going, neighborhoods: selectedNeighborhoods, zone: selectedZone, hubs: selectedHubs, campus: selectedCampus, date: selectedDate)
        delegate?.searchedForRide(withParameters: searchParams)
        
        self.performSegue(withIdentifier: "showResultsUnwind", sender: self)
    }
    
    @IBAction func didTapDate(_ sender: Any) {
        self.view.endEditing(true)
        let title = directionControl.selectedSegmentIndex == 0 ? PlaceService.Institution.goingLabel : PlaceService.Institution.leavingLabel
        let datePicker = ActionSheetDatePicker.init(title: title, datePickerMode: .dateAndTime, selectedDate: self.selectedDate, target: self, action: #selector(timeWasSelected(selectedTime:)), origin: sender)
        datePicker?.minuteInterval = 30
        datePicker?.minimumDate = Date.currentHour
        datePicker?.show()
    }
    
    @IBAction func selectCenterTapped(_ sender: Any) {
        let selectionVC = HubSelectionViewController.init(selectionType: .manySelection, hubTypeDirection: .centers)
        selectionVC.delegate = self
        self.navigationController?.show(selectionVC, sender: self)
    }
    
    @IBAction func selectNeighborhoodTapped(_ sender: Any) {
        let selectionVC = NeighborhoodSelectionViewController.init(selectionType: .manySelection)
        selectionVC.delegate = self
        self.navigationController?.show(selectionVC, sender: self)
    }
    
    
    // MARK: Selection Methods
    
    @objc func timeWasSelected(selectedTime: Date) {
        selectedDate = selectedTime
    }
    
    func hasSelected(hubs: [String], inCampus campus: String) {
        self.selectedCampus = campus
        self.selectedHubs = hubs
    }
    
    func hasSelected(neighborhoods: [String], inZone zone: String) {
        self.selectedZone = zone
        self.selectedNeighborhoods = neighborhoods
    }
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResultsUnwind" {
            let searchResultsVC = segue.destination as! SearchResultsViewController
            searchResultsVC.previouslySelectedSegmentIndex = self.directionControl.selectedSegmentIndex
        }
    }

}
