import UIKit

@objc enum SelectionType: Int {
    case oneSelection
    case manySelection
}

class FirstSelectionViewController: UITableViewController, SecondSelectionDelegate {
    
    var selectionType: SelectionType = .oneSelection
    var selectedFirstLevel = String()
    var firstLevelOptions: [String] = []
    var dictionarySelection: [String :[String]] = [:]
    var dictionaryColors: [String :UIColor] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        let cellNib = UINib.init(nibName: "SelectionCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "Selection Cell")
    }
    
    func hasSelected(selections: [String], inFirstLevel firstLevel: String) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func color(forCell cell: String) -> UIColor {
        return  dictionaryColors[cell] ?? .darkGray
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firstLevelOptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Selection Cell", for: indexPath) as! SelectionCell

        let cellTitle = firstLevelOptions[indexPath.row]
        let cellColor = color(forCell: cellTitle)
        
        cell.setupCell(on: .firstLevel, withTitle: cellTitle, andColor: cellColor)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFirstLevel = self.firstLevelOptions[indexPath.row]
        
        guard let secondLevelOptions = dictionarySelection[selectedFirstLevel] else {
            if selectionType == .manySelection {
                self.hasSelected(selections: [selectedFirstLevel], inFirstLevel: selectedFirstLevel)
            } else {
                if selectedFirstLevel == "Outra" {
                    let otherNeighborhoodVC = ZoneSelectionInputViewController()
                    otherNeighborhoodVC.delegate = self
                    self.navigationController?.show(otherNeighborhoodVC, sender: self)
                } else {
                    self.hasSelected(selections: [selectedFirstLevel], inFirstLevel: selectedFirstLevel)
                }
            }
            return
        }
        
        // Open SecondSelectionViewController
        let secondVC = SecondSelectionViewController()
        secondVC.selectedFirstLevel = self.selectedFirstLevel
        secondVC.selectionType = self.selectionType
        secondVC.secondLevelOptions = secondLevelOptions.sorted()
        secondVC.cellColor = color(forCell: selectedFirstLevel)
        secondVC.delegate = self
        self.navigationController?.show(secondVC, sender: self)
    }

}
