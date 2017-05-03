import UIKit

class SelectionCell: UITableViewCell {

    enum CellLevel {
        case firstLevel
        case secondLevel
    }
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var colorDetail: UIView!
    
    var cellColor: UIColor = UIColor.black
    var cellLevel: CellLevel = .firstLevel
    
    func setupCell(on level: CellLevel, withTitle title: String, andColor color: UIColor) {
        self.cellLevel = level
        self.cellLabel.text = title
        self.cellColor = color
        
        updateStyle()
    }
    
    func updateStyle() {
        self.colorDetail.backgroundColor = self.cellColor
        self.cellLabel.textColor = self.cellColor
        
        if self.cellLevel == .secondLevel {
            self.accessoryType = self.isSelected ? .checkmark : .none
        } else {
            self.accessoryType = .disclosureIndicator
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        updateStyle()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        updateStyle()
    }
    
}
