import UIKit
import ActionSheetPicker_3_0

@objc protocol SearchRideDelegate: class {
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
        
        // Load last direction
        directionControl.selectedSegmentIndex = previouslySelectedSegmentIndex
        
        // Load last searched zone, neighborhoods, campus and centers
        if let lastSearchedZone = self.userDefaults.string(forKey: CaronaePreferenceLastSearchedZoneKey),
            let lastSearchedNeighborhoods = self.userDefaults.stringArray(forKey: CaronaePreferenceLastSearchedNeighborhoodsKey),
            let lastSearchedCampus = self.userDefaults.string(forKey: CaronaePreferenceLastSearchedCampusKey),
            let lastSearchedCenters = self.userDefaults.stringArray(forKey: CaronaePreferenceLastSearchedCentersKey) {
            selectedZone = lastSearchedZone
            selectedNeighborhoods = lastSearchedNeighborhoods
            selectedCampus = lastSearchedCampus
            selectedHubs = lastSearchedCenters
        } else {
            selectedZone = ""
            selectedNeighborhoods = [CaronaeAllNeighborhoodsText]
            selectedCampus = ""
            selectedHubs = [CaronaeAllCampusesText]
        }
        
        // Load last searched date
        if let lastSearchedDate = self.userDefaults.object(forKey: CaronaePreferenceLastSearchedDateKey) as? Date, lastSearchedDate.isInTheFuture() {
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
        self.userDefaults.setValuesForKeys([CaronaePreferenceLastSearchedZoneKey: self.selectedZone!,
                                            CaronaePreferenceLastSearchedNeighborhoodsKey: self.selectedNeighborhoods!,
                                            CaronaePreferenceLastSearchedCampusKey: self.selectedCampus!,
                                            CaronaePreferenceLastSearchedCentersKey: self.selectedHubs!,
                                            CaronaePreferenceLastSearchedDateKey: self.selectedDate!])
        
        let going = (self.directionControl.selectedSegmentIndex == 0)
        
        let searchParams = FilterParameters(going: going, neighborhoods: selectedNeighborhoods, zone: selectedZone, hubs: selectedHubs, campus: selectedCampus, date: selectedDate)
        delegate?.searchedForRide(withParameters: searchParams)
        
        self.performSegue(withIdentifier: "showResultsUnwind", sender: self)
    }
    
    @IBAction func didTapDate(_ sender: Any) {
        self.view.endEditing(true)
        let datePicker = ActionSheetDatePicker.init(title: "Hora", datePickerMode: .dateAndTime, selectedDate: self.selectedDate, target: self, action: #selector(timeWasSelected(selectedTime:)), origin: sender)
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
    
    func timeWasSelected(selectedTime: Date) {
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
