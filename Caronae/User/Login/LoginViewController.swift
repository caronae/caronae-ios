import SafariServices
import SVProgressHUD
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var loginButton: CaronaeGradientButton!
    var authController = AuthenticationController()
    
    static func viewController() -> LoginViewController
    {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "InitialTokenScreen") as! LoginViewController
        viewController.modalTransitionStyle = .flipHorizontal
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    // MARK: IBActions
    
    @IBAction func openLogin() {
        self.authController.openLogin()
    }
    
}

