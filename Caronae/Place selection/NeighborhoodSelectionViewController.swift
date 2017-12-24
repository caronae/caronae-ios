import UIKit
import SVProgressHUD

@objc protocol NeighborhoodSelectionDelegate: class {
    func hasSelected(neighborhoods: [String], inZone zone: String)
}

class NeighborhoodSelectionViewController: SelectionViewController {
    
    @objc required convenience init(selectionType: SelectionType) {
        self.init()
        self.selectionType = selectionType
    }

    @objc weak var delegate: NeighborhoodSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Zona"
        
        SVProgressHUD.show()
        PlaceService.instance.getZones(success: { zones, options, colors, shouldReload in
            if self.selectionType == .manySelection {
                self.levelOptions = [CaronaeAllNeighborhoodsText]
            }
            self.levelOptions.append(contentsOf: zones)
            self.dictionarySelection = options
            self.dictionaryColors = colors
            if shouldReload {
                self.tableView.reloadData()
            }
            SVProgressHUD.dismiss()
        }, error: { error in
            SVProgressHUD.dismiss()
            NSLog("Error getting zones (\(error.localizedDescription))")
            CaronaeAlertController.presentOkAlert(withTitle: "Não foi possível carregar as localidades", message: "Por favor, tente novamente. \(error.localizedDescription).", handler: {
                self.navigationController?.popToRootViewController(animated: true)
            })
        })
    }
    
    override func hasSelected(selections: [String], inFirstLevel firstLevel: String) {
        super.hasSelected(selections: selections, inFirstLevel: firstLevel)
        
        delegate?.hasSelected(neighborhoods: selections, inZone: firstLevel)
    }

}
