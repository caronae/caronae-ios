import SafariServices
import SVProgressHUD
import UIKit

class TokenViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var authFieldsView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIImageView!
    
    static func tokenViewController() -> TokenViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InitialTokenScreen") as! TokenViewController
        viewController.modalTransitionStyle = .flipHorizontal
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        authButton.isEnabled = false
        tokenTextField.delegate = self
        idTextField.delegate = self
    }
    
    func authenticateWithUserAndToken() {
        let user = idTextField.text!
        let token = tokenTextField.text!
        authenticate(withUser: user, token: token)
    }

    func authenticate(withUser user: String, token: String) {
        authButton.isEnabled = false
        SVProgressHUD.show()
        
        UserService.instance.signIn(withUser: user, token: token, success: { _ in
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
    
    
    // MARK: IBActions
    
    @IBAction func signInWithIntranet() {
        SignInViewController.presentFromViewController(self, delegate: self)
    }
    
    @IBAction func signInWithCredentials() {        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.bottomBackgroundView.frame.origin.y += 30
            self.authFieldsView.frame.origin.y += 30
            self.buttonsView.alpha = 0
            self.authFieldsView.alpha = 1
        })
    }
    
    @IBAction func didTapAuthenticateButton() {
        authenticateWithUserAndToken()
    }
    
}

extension TokenViewController: CaronaeSignInDelegate {
    func caronaeDidSignInWithSuccess(user: String, token: String) {
        authenticate(withUser: user, token: token)
    }
    
    func caronaeSignInFailed() {
        NSLog("Authentication failed")
    }
}

extension TokenViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tokenTextField:
            authenticateWithUserAndToken()
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
