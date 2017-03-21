import SafariServices
import SVProgressHUD
import UIKit

class SignInViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var authFieldsView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var signInMode = CaronaeSignInMode.external {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.buttonsView.alpha = self.signInMode == .credentials ? 0 : 1
                self.welcomeLabel.alpha = self.signInMode == .credentials ? 0 : 1
                self.bottomBackgroundView.alpha = self.signInMode == .credentials ? 0 : 1
                self.authFieldsView.alpha = self.signInMode == .credentials ? 1 : 0
            })
        }
    }
    
    static func signInViewController() -> SignInViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: SignInViewController.self)) as! SignInViewController
        viewController.modalTransitionStyle = .flipHorizontal
        return viewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if authFieldsView.alpha != 0 {
            idTextField.becomeFirstResponder()
        }
    }
    
    func authenticateWithUserAndToken() {
        let user = idTextField.text!
        let token = tokenTextField.text!
        authenticate(withUser: user, token: token)
    }

    func authenticate(withUser user: String, token: String) {
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
        })
    }
    
    
    // MARK: IBActions
    
    @IBAction func signInWithIntranet() {
        ExternalSignInViewController.presentFromViewController(self, delegate: self)
    }
    
    @IBAction func signInWithCredentials() {
        idTextField.becomeFirstResponder()
        signInMode = .credentials
    }
    
    @IBAction func cancelSignInWithCredentials() {
        idTextField.resignFirstResponder()
        tokenTextField.resignFirstResponder()
        signInMode = .external
    }
}

extension SignInViewController: ExternalSignInDelegate {
    func externalSignInWasSuccessful(user: String, token: String) {
        authenticate(withUser: user, token: token)
    }
    
    func externalSignInFailed() {
        NSLog("Authentication failed")
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == idTextField {
            tokenTextField.becomeFirstResponder()
        } else if textField == tokenTextField && idTextField.hasText && tokenTextField.hasText {            authenticateWithUserAndToken()
        }
        
        return true
    }
}

enum CaronaeSignInMode {
    case external
    case credentials
}
