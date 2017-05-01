import UIKit

@objc enum SelectionType: Int {
    case OneSelection
    case ManySelection
}

class FirstSelectionViewController: UITableViewController, SecondSelectionDelegate {
    
    var selectionType: SelectionType = .OneSelection
    var selectedFirstLevel = String()
    var firstLevelOptions: [String] = []
    var dictionarySelection: [String :[String]] = [:]
    var dictionaryColors: [String :UIColor] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func hasSelected(selections: [String], inFirstLevel firstLevel: String) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func color(forCell cell: String) -> UIColor {
        var color = dictionaryColors[cell]
        if color == nil {
            color = UIColor.darkGray
        }
        return color!
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firstLevelOptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Selection Cell", for: indexPath) as! SelectionCell

        let cellTitle = firstLevelOptions[indexPath.row]
        let cellColor = color(forCell: cellTitle)
        
        cell.setupCell(on: .FirstLevel, withTitle: cellTitle, andColor: cellColor)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFirstLevel = self.firstLevelOptions[indexPath.row]
        
        if dictionarySelection[selectedFirstLevel] == nil {
            if selectionType == .ManySelection {
                self.hasSelected(selections: [selectedFirstLevel], inFirstLevel: selectedFirstLevel)
            } else {
                if selectedFirstLevel == "Outra" {
                    self.performSegue(withIdentifier: "OtherNeighborhood", sender: self)
                } else {
                    self.hasSelected(selections: [selectedFirstLevel], inFirstLevel: selectedFirstLevel)
                }
            }
            return
        }
        
        performSegue(withIdentifier: "ViewSecondLevel", sender: self)
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewSecondLevel" {
            let secondVC = segue.destination as! SecondSelectionViewController
            secondVC.selectedFirstLevel = self.selectedFirstLevel
            secondVC.selectionType = self.selectionType
            secondVC.dictionarySelection = self.dictionarySelection
            secondVC.cellColor = color(forCell: selectedFirstLevel)
            secondVC.delegate = self
        } else if segue.identifier == "OtherNeighborhood" {
            let zoneSelectionInputVC = segue.destination as! ZoneSelectionInputViewController
            zoneSelectionInputVC.delegate = self
        }
    }

}
