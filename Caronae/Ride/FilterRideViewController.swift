import UIKit
import ActionSheetPicker_3_0

class FilterRideViewController: UIViewController, ZoneSelectionDelegate {
    @IBOutlet weak var neighborhoodButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    
    var selectedNeighborhoods: [String]? {
        didSet {
            var buttonTitle = String()
            
            for i in 0..<selectedNeighborhoods!.count {
                if i > 2 {
                    buttonTitle = String(format: "%@ + %lu", buttonTitle, selectedNeighborhoods!.count-i)
                    break;
                }
                buttonTitle = buttonTitle.appending(selectedNeighborhoods![i])
                if i < selectedNeighborhoods!.count - 1 && i < 2 {
                    buttonTitle = buttonTitle.appending(", ")
                }
            }
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
        if let lastFilteredNeighborhoods = self.userDefaults.array(forKey: CaronaePreferenceLastFilteredNeighborhoodsKey) as? [String],
            let lastFilteredCenter = self.userDefaults.string(forKey: CaronaePreferenceLastFilteredCenterKey) {
            self.selectedNeighborhoods = lastFilteredNeighborhoods
            self.selectedHub = lastFilteredCenter
        } else {
            self.selectedHub = self.hubs?.first
        }
        
        self.centerButton.setTitle(self.selectedHub, for: .normal)
    }
    
    
    // MARK: IBActions
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapFilterButton(_ sender: Any) {
        guard isSearchValid() else {
            CaronaeAlertController.presentOkAlert(withTitle: "Nenhum bairro selecionado", message: "Ops! Parece que você esqueceu de selecionar em quais bairros está pesquisando a carona.")
            return
        }
        
        // Save filter parameters
        self.userDefaults.setValuesForKeys([CaronaePreferenceFilterIsEnabledKey: true,
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
        // Test if user has selected a neighborhood
        if let selectedNeighborhoods = self.selectedNeighborhoods, selectedNeighborhoods.count > 0 {
            return true
        }
        return false
    }

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewZones" {
            let zoneSelectionVC = segue.destination as! ZoneSelectionViewController
            zoneSelectionVC.type = ZoneSelectionZone
            zoneSelectionVC.neighborhoodSelectionType = NeighborhoodSelectionMany
            zoneSelectionVC.delegate = self
        } else if segue.identifier == "didTapFilterUnwind" {
            let allRidesVC = segue.destination as! AllRidesViewController
            allRidesVC.enableFilterRides()
        }
    }

}
