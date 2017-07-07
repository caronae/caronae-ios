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
    
    var hubTypeDirection: HubTypeDirection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Campi"
        
        if selectionType == .manySelection {
            firstLevelOptions = [CaronaeAllCampusesText]
        }
        
        if hubTypeDirection == .hubs {
            dictionarySelection = CaronaeConstants.defaults().hubs as! [String : [String]]
        } else {
            dictionarySelection = CaronaeConstants.defaults().centers as! [String : [String]]
        }
        dictionaryColors = CaronaeConstants.defaults().campusColors as! [String : UIColor]
        firstLevelOptions.append(contentsOf: CaronaeConstants.defaults().campuses as! [String])
    }
    
    override func hasSelected(selections: [String], inFirstLevel firstLevel: String) {
        super.hasSelected(selections: selections, inFirstLevel: firstLevel)
        
        delegate?.hasSelected(hubs: selections, inCampus: firstLevel)
    }

}
