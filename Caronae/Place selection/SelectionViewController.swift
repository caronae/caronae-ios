import UIKit

@objc enum SelectionType: Int {
    case oneSelection
    case manySelection
}

enum SelectionLevel {
    case firstLevel
    case secondLevel
}

@objc protocol SelectionDelegate: class {
    func hasSelected(selections: [String], inFirstLevel firstLevel: String)
}

class SelectionViewController: UITableViewController, SelectionDelegate {
    
    weak var secondDelegate: SelectionDelegate?
    
    var selectionLevel: SelectionLevel = .firstLevel
    var selectionType: SelectionType = .oneSelection
    var levelOptions = [String]()
    var dictionarySelection = [String :[String]]()
    var dictionaryColors = [String :UIColor]()
    var selectedFirstLevel = String()
    var colorFirstLevel: UIColor?
    var doneButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSecondSelectionIfNeeded()
        
        self.tableView.separatorStyle = .none
        let cellNib = UINib.init(nibName: "SelectionCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "Selection Cell")
    }
    
    func configureSecondSelectionIfNeeded() {
        self.title = self.selectedFirstLevel
        
        if selectionLevel == .secondLevel && selectionType == .manySelection && levelOptions.count != 1 {
            self.doneButton = UIBarButtonItem(title: "Sel. todos", style: .done, target: self, action: #selector(finishSelection))
            self.navigationItem.rightBarButtonItem = self.doneButton
            self.tableView.allowsMultipleSelection = true
        }
    }
    
    func color(forCell cell: String) -> UIColor {
        return dictionaryColors[cell] ?? .darkGray
    }
    
    func hasSelected(selections: [String], inFirstLevel firstLevel: String) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func handleFirstSelection(_ selectedFirstLevel: String) {
        self.selectedFirstLevel = selectedFirstLevel
        guard let secondLevelOptions = dictionarySelection[selectedFirstLevel] else {
            if selectionType == .manySelection {
                self.hasSelected(selections: [selectedFirstLevel], inFirstLevel: selectedFirstLevel)
            } else {
                // selectedFirstLevel == CaronaeOtherZoneText
                let otherNeighborhoodVC = ZoneSelectionInputViewController()
                otherNeighborhoodVC.delegate = self
                self.navigationController?.show(otherNeighborhoodVC, sender: self)
            }
            return
        }
        
        if [selectedFirstLevel] == secondLevelOptions {
            self.hasSelected(selections: secondLevelOptions, inFirstLevel: selectedFirstLevel)
            return
        }
        
        // Open SelectionViewController for secondLevel
        let secondVC = SelectionViewController()
        secondVC.selectionLevel = .secondLevel
        secondVC.selectionType = self.selectionType
        secondVC.levelOptions = secondLevelOptions.sorted()
        secondVC.selectedFirstLevel = self.selectedFirstLevel
        secondVC.colorFirstLevel = color(forCell: selectedFirstLevel)
        secondVC.secondDelegate = self
        self.navigationController?.show(secondVC, sender: self)
    }
    
    func finishSelection() {
        self.navigationController?.popToRootViewController(animated: true)
        
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        var selections: [String] = []
        
        if (selectionType == .manySelection && (selectedIndexPaths == nil || selectedIndexPaths?.count == levelOptions.count)) {
            selections = [selectedFirstLevel]
        } else {
            for indexPath in selectedIndexPaths! {
                selections.append(levelOptions[indexPath.row])
            }
        }
        
        secondDelegate?.hasSelected(selections: selections, inFirstLevel: selectedFirstLevel)
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levelOptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Selection Cell", for: indexPath) as! SelectionCell

        let cellTitle = levelOptions[indexPath.row]
        let cellColor = self.colorFirstLevel ?? color(forCell: cellTitle)
        
        cell.setupCell(on: selectionLevel, withTitle: cellTitle, andColor: cellColor)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectionLevel == .firstLevel {
            handleFirstSelection(self.levelOptions[indexPath.row])
        } else {
            if selectionType == .oneSelection || levelOptions.count == 1 {
                finishSelection()
                return
            }
            updateFinishButton()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateFinishButton()
    }
    
    func updateFinishButton() {
        if let _ = tableView.indexPathsForSelectedRows {
            doneButton.title = "OK"
        } else {
            doneButton.title = "Sel. todos"
        }
    }

}
