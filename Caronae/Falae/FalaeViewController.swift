import UIKit
import ActionSheetPicker_3_0
import SVProgressHUD

class FalaeViewController: UIViewController {
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    var reportedUser: User?
    let messageTypes = ["Reclamação", "Sugestão", "Denúncia", "Dúvida"]
    var selectedTypeIndex = 0
    var selectedType = "Reclamação" {
        didSet {
            typeButton.setTitle(selectedType, for: .normal)
            self.selectedTypeIndex = messageTypes.index(of: selectedType)!
        }
    }
    
    var deviceName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let reportedUser = reportedUser {
            selectedType = "Denúncia"
            typeButton.isEnabled = false
            subjectTextField.text = String(format: "Denúncia sobre usuário %@ (id: %ld)", reportedUser.name, reportedUser.id)
            subjectTextField.isEnabled = false
        }
    }
    
    func setReport(user: User) {
        reportedUser = user
    }
    
    
    // MARK: IBActions
    
    @IBAction func didTapSelectTypeButton(_ sender: Any) {
        view.endEditing(true)
        ActionSheetStringPicker.show(withTitle: "Qual o motivo do seu contato?",
                                     rows: messageTypes, initialSelection: selectedTypeIndex,
                                     doneBlock: { _, _, selectedValue in
                                        self.selectedType = selectedValue as! String
                                     }, cancel: nil, origin: sender)
    }
    
    @IBAction func didTapSendButton(_ sender: Any) {
        view.endEditing(true)
        
        let messageText = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if messageText.isEmpty {
            CaronaeAlertController.presentOkAlert(withTitle: "Ops!", message: "Parece que você esqueceu de preencher sua mensagem.")
            return
        }
        let subject = String(format: "[%@] %@", selectedType, subjectTextField.text!)
        
        let appVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let appBuildString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let versionBuildString = String(format: "%@ (build %@)", appVersionString, appBuildString)
        let osVersion = UIDevice.current.systemVersion
        let device = deviceName
        let message = String(format: "%@\n\n--------------------------------\nDevice: %@ (iOS %@)\nVersão do app: %@", messageText, device, osVersion, versionBuildString)
        
        sendButton.isEnabled = false
        SVProgressHUD.show()
        FalaeService.instance.sendMessage(subject: subject, message: message, success: {
            SVProgressHUD.dismiss()
            CaronaeAlertController.presentOkAlert(withTitle: "Mensagem enviada!", message: "Obrigado por nos mandar uma mensagem. Nossa equipe irá entrar em contato em breve.", handler: {
                self.navigationController?.popViewController(animated: true)
            })
        }) { error in
            self.sendButton.isEnabled = true
            SVProgressHUD.dismiss()
            NSLog("Error: %@", error!.localizedDescription)
            CaronaeAlertController.presentOkAlert(withTitle: "Mensagem não enviada", message: "Ocorreu um erro enviando sua mensagem. Verifique sua conexão e tente novamente.")
        }
    }
}
