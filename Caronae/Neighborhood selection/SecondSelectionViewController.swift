import UIKit

protocol SecondSelectionDelegate: class {
    func hasSelected(selections: [String], inFirstLevel firstLevel: String)
}

class SecondSelectionViewController: UITableViewController {
    
    weak var delegate: SecondSelectionDelegate?
    
    var selectionType: SelectionType = .oneSelection
    var selectedFirstLevel = String()
    var secondLevelOptions: [String] = []
    var dictionarySelection: [String :[String]] = [:]
    var doneButton: UIBarButtonItem = UIBarButtonItem()
    var cellColor = UIColor.black
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.selectedFirstLevel
        
        secondLevelOptions = dictionarySelection[selectedFirstLevel]!
        
        if selectionType == .manySelection {
            self.doneButton = UIBarButtonItem(title: "Sel. todos", style: .done, target: self, action: #selector(finishSelection))
            self.navigationItem.rightBarButtonItem = self.doneButton
            self.tableView.allowsMultipleSelection = true
        }
    }
    
    func finishSelection() {
        self.navigationController?.popToRootViewController(animated: true)
        
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        var selections: [String] = []
        
        if (selectedIndexPaths == nil || selectedIndexPaths?.count == secondLevelOptions.count) {
            selections = [selectedFirstLevel]
        } else {
            for indexPath in selectedIndexPaths! {
                selections.append(secondLevelOptions[indexPath.row])
            }
        }
        
        delegate?.hasSelected(selections: selections, inFirstLevel: selectedFirstLevel)
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return secondLevelOptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Selection Cell", for: indexPath) as! SelectionCell
        
        let title = secondLevelOptions[indexPath.row]
        
        cell.setupCell(on: .secondLevel, withTitle: title, andColor: cellColor)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectionType == .oneSelection {
            finishSelection()
            return
        }
        
        updateFinishButton()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateFinishButton()
    }

    func updateFinishButton() {
        if let numberOfSelections = tableView.indexPathsForSelectedRows?.count {
            doneButton.title = (numberOfSelections > 0) ? "OK" : "Sel. todos"
        }
    }

}
    

