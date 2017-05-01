import UIKit

@objc protocol HubSelectionDelegate: class {
    func hasSelected(hubs: [String])
}

@objc class HubSelectionViewController: FirstSelectionViewController {
    
    static func makeVC(selectionType: SelectionType, hubTypeDirection: HubTypeDirection) -> HubSelectionViewController {
        let selectionStoryboard = UIStoryboard(name: "SelectionViewController", bundle: nil)
        let selectionBaseVC = selectionStoryboard.instantiateViewController(withIdentifier: "FirstSelectionViewController") as! FirstSelectionViewController
        object_setClass(selectionBaseVC, HubSelectionViewController.self)
        
        let selectionVC = selectionBaseVC as! HubSelectionViewController
        selectionVC.selectionType = selectionType
        selectionVC.hubTypeDirection = hubTypeDirection
        
        return selectionVC
    }
    
    @objc enum HubTypeDirection: Int {
        case Hubs
        case Centers
    }

    weak var delegate: HubSelectionDelegate?
    
    var hubTypeDirection: HubTypeDirection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Campi"
        
        if selectionType == .ManySelection {
            firstLevelOptions = [CaronaeAllHubsText]
        }
        
        if hubTypeDirection == .Hubs {
            dictionarySelection = CaronaeConstants.defaults().hubs as! [String : [String]]
        } else {
            dictionarySelection = CaronaeConstants.defaults().centers as! [String : [String]]
        }
        dictionaryColors = CaronaeConstants.defaults().campusColors as! [String : UIColor]
        firstLevelOptions.append(contentsOf: CaronaeConstants.defaults().campuses as! [String])
    }
    
    override func hasSelected(selections: [String], inFirstLevel firstLevel: String) {
        super.hasSelected(selections: selections, inFirstLevel: firstLevel)
        
        delegate?.hasSelected(hubs: selections)
    }

}
