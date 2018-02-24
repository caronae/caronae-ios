import SafariServices
import SVProgressHUD
import UIKit

class TokenViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var loginButton: CaronaeGradientButton!
    var authController = AuthenticationController()
    
    static func tokenViewController() -> TokenViewController
    {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "InitialTokenScreen") as! TokenViewController
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

