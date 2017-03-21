import SafariServices
import SVProgressHUD
import UIKit

class TokenViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var authFieldsView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    static func tokenViewController() -> TokenViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InitialTokenScreen") as! TokenViewController
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
        SignInViewController.presentFromViewController(self, delegate: self)
    }
    
    @IBAction func signInWithCredentials() {
        idTextField.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.buttonsView.alpha = 0
            self.authFieldsView.alpha = 1
            self.welcomeLabel.alpha = 0
            self.bottomBackgroundView.alpha = 0
        })
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
        if textField == idTextField {
            tokenTextField.becomeFirstResponder()
        } else if textField == tokenTextField && idTextField.hasText && tokenTextField.hasText {            authenticateWithUserAndToken()
        }
        
        return true
    }
}
