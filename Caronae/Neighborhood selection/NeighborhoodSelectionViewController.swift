import UIKit

@objc protocol NeighborhoodSelectionDelegate: class {
    func hasSelected(neighborhoods: [String], inZone zone: String)
}

@objc class NeighborhoodSelectionViewController: FirstSelectionViewController {
    
    static func makeVC(selectionType: SelectionType) -> NeighborhoodSelectionViewController {
        let selectionStoryboard = UIStoryboard(name: "SelectionViewController", bundle: nil)
        let selectionBaseVC = selectionStoryboard.instantiateViewController(withIdentifier: "FirstSelectionViewController") as! FirstSelectionViewController
        object_setClass(selectionBaseVC, NeighborhoodSelectionViewController.self)
        
        let selectionVC = selectionBaseVC as! NeighborhoodSelectionViewController
        selectionVC.selectionType = selectionType
        
        return selectionVC
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
