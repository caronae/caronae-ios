import UIKit

class ZoneSelectionInputViewController: UIViewController {
    
    weak var delegate: SecondSelectionDelegate?

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var neighborhoodTextField: CaronaeTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        neighborhoodTextField.becomeFirstResponder()
    }
    
    func finishSelection() {
        self.navigationController?.popToRootViewController(animated: true)
        delegate?.hasSelected(selections: [self.neighborhoodTextField.text!], inFirstLevel: "Outros")
    }

    @IBAction func didTapDoneButton(_ sender: Any) {
        if let location = neighborhoodTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !location.isEmpty {
            finishSelection()
        }
    }
    
}
