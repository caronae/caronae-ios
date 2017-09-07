import UIKit

class ZoneSelectionInputViewController: UIViewController {
    
    weak var delegate: SecondSelectionDelegate?

    @IBOutlet weak var neighborhoodTextField: CaronaeTextField!
    
    override func loadView() {
        Bundle.main.loadNibNamed("ZoneSelectionInput", owner: self, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Outra região"
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.backgroundColor = .white
        self.edgesForExtendedLayout = []
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(didTapDoneButton))
        
        neighborhoodTextField.becomeFirstResponder()
    }
    
    func finishSelection() {
        self.navigationController?.popToRootViewController(animated: true)
        delegate?.hasSelected(selections: [self.neighborhoodTextField.text!], inFirstLevel: CaronaeOtherNeighborhoodsText)
    }

    func didTapDoneButton() {
        if let location = neighborhoodTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !location.isEmpty {
            finishSelection()
        }
    }
    
}
