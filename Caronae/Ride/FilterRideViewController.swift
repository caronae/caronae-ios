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
    var userDefaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Load last filter (or active)
        self.hubs = ["Todos os Centros"]
        self.hubs?.append(contentsOf: CaronaeConstants.defaults().centers as! [String])
        self.selectedHub = self.hubs?.first
        self.centerButton.setTitle(self.selectedHub, for: .normal)
        
        //// Load last searched neighborhoods
        //NSArray *lastSearchedNeighborhoods = [self.userDefaults arrayForKey:CaronaePreferenceLastSearchedNeighborhoodsKey];
        //if (lastSearchedNeighborhoods) {
        //    self.neighborhoods = lastSearchedNeighborhoods;
        //}
        
        //// Load last searched center
        //NSString *lastSearchedCenter = [self.userDefaults stringForKey:CaronaePreferenceLastSearchedCenterKey];
        //self.hubs = [@[@"Todos os Centros"] arrayByAddingObjectsFromArray:[CaronaeConstants defaults].centers];
        //if (lastSearchedCenter) {
        //    self.selectedHub = lastSearchedCenter;
        //} else {
        //    self.selectedHub = self.hubs.firstObject;
        //}
        //[self.centerButton setTitle:self.selectedHub forState:UIControlStateNormal];
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
        
        //TODO: save filter
        
        // Save search parameters for the next search
        //[self.userDefaults setObject:self.neighborhoods forKey:CaronaePreferenceLastSearchedNeighborhoodsKey];
        //[self.userDefaults setObject:self.selectedHub forKey:CaronaePreferenceLastSearchedCenterKey];
        //[self.userDefaults setObject:self.searchedDate forKey:CaronaePreferenceLastSearchedDateKey];
        
        //var going = true
        //[self.delegate searchedForRideWithCenter: ([self.selectedHub isEqual: self.hubs[0]] ? @"" : self.selectedHub) andNeighborhoods:self.neighborhoods onDate:self.searchedDate going:going];
        
        //[self performSegueWithIdentifier:@"showResultsUnwind" sender:nil];
        
        self.dismiss(animated: true, completion: nil)
        
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
        //} else if segue.identifier == "showResultsUnwind" {
            //SearchResultsViewController *vc = segue.destinationViewController;
            //vc.previouslySelectedSegmentIndex = self.directionControl.selectedSegmentIndex;
        }
    }

}
