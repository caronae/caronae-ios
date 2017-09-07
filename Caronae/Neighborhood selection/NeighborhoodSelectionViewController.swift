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
        
        PlaceService.instance.getZones(success: { zones, options, colors in
            self.firstLevelOptions.append(contentsOf: zones)
            self.dictionarySelection = options
            self.dictionaryColors = colors
        }, error: { error in
            NSLog("Error updating places (\(error.localizedDescription))")
        })
    }
    
    override func hasSelected(selections: [String], inFirstLevel firstLevel: String) {
        super.hasSelected(selections: selections, inFirstLevel: firstLevel)
        
        delegate?.hasSelected(neighborhoods: selections, inZone: firstLevel)
    }

}
