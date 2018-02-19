import SafariServices
import SVProgressHUD
import UIKit

class TokenViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var loginButton: CaronaeGradientButton!
    var authController: AuthenticationController!
    
    static func tokenViewController() -> TokenViewController
    {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InitialTokenScreen") as! TokenViewController
        viewController.modalTransitionStyle = .flipHorizontal
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func authenticate(id: String, token: String) {
        loginButton.isEnabled = false
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
            self.loginButton.isEnabled = true
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
    
    @IBAction func openLogin() {
        if #available(iOS 11, *) {
            self.authController = AuthenticationController()
            self.authController.openLogin()
        }
    }
    
}

