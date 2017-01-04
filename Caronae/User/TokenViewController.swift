import SafariServices
import SVProgressHUD
import UIKit

class TokenViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var tokenTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        authButton.isEnabled = false
        tokenTextField.delegate = self
        idTextField.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(openIntranetLogin))
        welcomeLabel.addGestureRecognizer(tapRecognizer)
    }

    func authenticate() {
        let id = idTextField.text!
        let token = tokenTextField.text!
        
        authButton.isEnabled = false
        SVProgressHUD.show()
        
        UserService.instance.signIn(withID: id, token: token, success: { user in
            // TODO: check if we need to show the screen to complete the profile
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "ViewHome", sender: self)
        }, error: { error in
            var errorMessage: String!
            
            switch error {
            case .invalidCredentials:
                errorMessage = "Chave não autorizada. Verifique se a mesma foi digitada corretamente e tente de novo."
            case .invalidResponse:
                errorMessage = "Ocorreu um erro carregando seu perfil."
            default:
                errorMessage = "Ocorreu um erro autenticando com o servidor do Caronaê. Por favor, tente novamente."
            }
            
            SVProgressHUD.dismiss()
            CaronaeAlertController.presentOkAlert(withTitle: "Não foi possível autenticar", message: errorMessage)
            self.authButton.isEnabled = true
        })
    }
    
    func openIntranetLogin() {
        let intranetURL = URL(string: CaronaeIntranetURLString)!
        if #available(iOS 9, *) {
            let safariViewController = SFSafariViewController(url: intranetURL, entersReaderIfAvailable: false)
            present(safariViewController, animated: true)
        } else {
            UIApplication.shared.openURL(intranetURL)
        }
    }

    // MARK: IBActions
    
    @IBAction func didTapAuthenticateButton(_ sender: Any) {
        authenticate()
    }
    
}

extension TokenViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tokenTextField:
            authenticate()
            return false
        case idTextField:
            if idTextField.hasText {
                tokenTextField.becomeFirstResponder()
            }
        default:
            break
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString!).replacingCharacters(in: range, with: string)
        switch textField {
        case idTextField:
            authButton.isEnabled = !text.isEmpty && tokenTextField.hasText
        default:
            authButton.isEnabled = !text.isEmpty && idTextField.hasText
        }
        
        return true
    }
}
