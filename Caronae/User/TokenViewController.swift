import SafariServices
import SVProgressHUD
import UIKit

class TokenViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var tokenTextField: UITextField!
    var authController: AuthenticationController!
    
    static func tokenViewController() -> TokenViewController
    {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InitialTokenScreen") as! TokenViewController
        viewController.modalTransitionStyle = .flipHorizontal
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if #available(iOS 11, *) {
            self.authController = AuthenticationController()
            self.authController.authenticate(success: { (idUFRJ: String, token: String) in
                NSLog("Authenticated with id '%@' and token '%@'", idUFRJ, token)
                self.authenticate(id: idUFRJ, token: token)
            })
        }

        authButton.isEnabled = false
        tokenTextField.delegate = self
        idTextField.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(openIntranetLogin))
        welcomeLabel.addGestureRecognizer(tapRecognizer)
    }

    func authenticate(id: String, token: String) {
        authButton.isEnabled = false
        SVProgressHUD.show()
        
        UserService.instance.signIn(withID: id, token: token, success: { _ in
            let rootViewController = TabBarController()
            UIApplication.shared.keyWindow?.replaceViewController(with: rootViewController)
        }, error: { error in
            var errorMessage: String!
            
            switch error.caronaeCode {
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
    
    @objc func openIntranetLogin() {
        let loginURL = URL(string: CaronaeURLString.login)!
        if #available(iOS 9, *) {
            let safariViewController = SFSafariViewController(url: loginURL, entersReaderIfAvailable: false)
            present(safariViewController, animated: true)
        } else {
            UIApplication.shared.openURL(loginURL)
        }
    }

    // MARK: IBActions
    
    @IBAction func didTapAuthenticateButton(_ sender: Any) {
        authenticate(id: idTextField.text!, token: tokenTextField.text!)
    }
    
}

extension TokenViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tokenTextField:
            authenticate(id: idTextField.text!, token: tokenTextField.text!)
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
