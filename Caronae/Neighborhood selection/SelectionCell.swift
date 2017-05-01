import UIKit

class SelectionCell: UITableViewCell {

    @objc enum CellLevel: Int {
        case FirstLevel
        case SecondLevel
    }
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var colorDetail: UIView!
    
    var cellColor: UIColor = UIColor.black
    var cellLevel: CellLevel = .FirstLevel
    
    func setupCell(on level: CellLevel, withTitle title: String, andColor color: UIColor) {
        self.cellLevel = level
        self.cellLabel.text = title
        self.cellColor = color
        
        updateStyle()
    }
    
    func updateStyle() {
        self.colorDetail.backgroundColor = self.cellColor
        self.cellLabel.textColor = self.cellColor
        
        if self.cellLevel == .SecondLevel {
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
