import UIKit

@objc protocol NeighborhoodSelectionDelegate: class {
    func hasSelected(neighborhoods: [String], inZone zone: String)
}

@objc class NeighborhoodSelectionViewController: FirstSelectionViewController {
    
    required convenience init(selectionType: SelectionType) {
        self.init()
        self.selectionType = selectionType
    }

    weak var delegate: NeighborhoodSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Zonas"
        
        if selectionType == .manySelection {
            firstLevelOptions = [CaronaeAllNeighborhoodsText]
        }
        
        dictionarySelection = CaronaeConstants.defaults().neighborhoods as! [String : [String]]
        dictionaryColors = CaronaeConstants.defaults().zoneColors as! [String : UIColor]
        firstLevelOptions.append(contentsOf: CaronaeConstants.defaults().zones as! [String])
    }
    
    override func hasSelected(selections: [String], inFirstLevel firstLevel: String) {
        super.hasSelected(selections: selections, inFirstLevel: firstLevel)
        
        delegate?.hasSelected(neighborhoods: selections, inZone: firstLevel)
    }

}
