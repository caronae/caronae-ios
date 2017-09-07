import UIKit

@objc protocol HubSelectionDelegate: class {
    func hasSelected(hubs: [String], inCampus campus: String)
}

@objc class HubSelectionViewController: FirstSelectionViewController {
    
    required convenience init(selectionType: SelectionType, hubTypeDirection: HubTypeDirection) {
        self.init()
        self.selectionType = selectionType
        self.hubTypeDirection = hubTypeDirection
    }
    
    @objc enum HubTypeDirection: Int {
        case hubs
        case centers
    }

    weak var delegate: HubSelectionDelegate?
    
    var numberOfCampi = 0
    var hubTypeDirection: HubTypeDirection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Campi"
        
        PlaceService.instance.getCampi(hubTypeDirection: hubTypeDirection!, success: { campi, options, colors in
            self.numberOfCampi = campi.count
            if self.selectionType == .manySelection && self.numberOfCampi > 1 {
                self.firstLevelOptions = [CaronaeAllCampiText]
            }
            self.firstLevelOptions.append(contentsOf: campi)
            self.dictionarySelection = options
            self.dictionaryColors = colors
            if self.numberOfCampi == 1 {
                self.handleSelection(campi.first!)
            }
        }, error: { error in
            NSLog("Error updating places (\(error.localizedDescription))")
        })
    }
    
    override func hasSelected(selections: [String], inFirstLevel firstLevel: String) {
        super.hasSelected(selections: selections, inFirstLevel: firstLevel)
        
        if self.numberOfCampi == 1 && selections == [firstLevel] {
            // Selected all hubs of the single campus. Behavior of selecting all campi.
            delegate?.hasSelected(hubs: [CaronaeAllCampiText], inCampus: CaronaeAllCampiText)
            return
        }
        
        delegate?.hasSelected(hubs: selections, inCampus: firstLevel)
    }

}
