import SafariServices
import SVProgressHUD
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var loginButton: CaronaeGradientButton!
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var changeLoginMethodButton: UIButton!
    
    var authController = AuthenticationController()
    
    private var isAutoLoginMethod: Bool! {
        didSet {
            changeLoginMethod()
        }
    }
    
    static func viewController() -> LoginViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "InitialTokenScreen") as! LoginViewController
        viewController.modalTransitionStyle = .flipHorizontal
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isAutoLoginMethod = true
        
        idTextField.delegate = self
        tokenTextField.delegate = self
    }

    
    // MARK: IBActions
    
    @IBAction func authenticate() {
        if isAutoLoginMethod {
            self.authController.openLogin()
        } else {
            view.endEditing(true)
            let id = idTextField.text!
            let token = tokenTextField.text!
            self.authController.authenticate(withIDUFRJ: id, token: token, callback: { error in
                guard error == nil else {
                    
                    NSLog("There was an error authenticating the user. %@", error!.description)
                    var errorMessage: String!
                    
                    switch error!.caronaeCode {
                    case .invalidCredentials:
                        errorMessage = "Chave não autorizada. Verifique se a mesma foi digitada corretamente e tente de novo."
                    case .invalidResponse:
                        errorMessage = "Ocorreu um erro carregando seu perfil."
                    default:
                        errorMessage = "Ocorreu um erro autenticando com o servidor do Caronaê. Por favor, tente novamente."
                    }
                    
                    CaronaeAlertController.presentOkAlert(withTitle: "Não foi possível autenticar", message: errorMessage)
                    return
                }
                
                NSLog("User was authenticated. Switching main view controller...")
                let rootViewController = TabBarController()
                UIApplication.shared.keyWindow?.replaceViewController(with: rootViewController)
            })
        }
    }
    
    @IBAction func didTapChangeLoginMethod() {
        view.endEditing(true)
        isAutoLoginMethod = !isAutoLoginMethod
    }
    
    
    func changeLoginMethod() {
        view.isUserInteractionEnabled = false
        
        if !isAutoLoginMethod {
            idTextField.text = ""
            tokenTextField.text = ""
        }
        
        let changeLoginMethodbuttonTitle = isAutoLoginMethod ? "Entrar manualmente" : "Entrar com universidade"
        let loginButtonTitle = isAutoLoginMethod ? "Entrar com universidade" : "Entrar"
        let loginButtonIcon = isAutoLoginMethod ? UIImage(named: "InstitutionIcon") : nil
        UIView.animate(withDuration: 0.25, animations: {
            if self.isAutoLoginMethod {
                self.idTextField.alpha = 0.0
                self.tokenTextField.alpha = 0.0
            } else {
                self.idTextField.isHidden = false
                self.tokenTextField.isHidden = false
            }
        }) { _ in
            UIView.animate(withDuration: 0.25, animations: {
                if self.isAutoLoginMethod {
                    self.idTextField.isHidden = true
                    self.tokenTextField.isHidden = true
                } else {
                    self.idTextField.alpha = 1.0
                    self.tokenTextField.alpha = 1.0
                }
            }) { _ in
                self.view.isUserInteractionEnabled = true
            }
            UIView.performWithoutAnimation {
                self.changeLoginMethodButton.setTitle(changeLoginMethodbuttonTitle, for: .normal)
                self.changeLoginMethodButton.layoutIfNeeded()
                self.loginButton.setTitle(loginButtonTitle, for: .normal)
                self.loginButton.setImage(loginButtonIcon, for: .normal)
                self.loginButton.layoutIfNeeded()
            }
        }
    }
}


// MARK: UITextFieldDelegate Methods

extension LoginViewController: UITextFieldDelegate {
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
}
