import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var welcomeImage: UIImageView!

    convenience init() {
        self.init(nibName: "WelcomeViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = UserService.instance.user!
        titleLabel.text = "Olá, " + user.firstName + "!"
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "NavigationBarLogo"))
        
        // workaround to trigger the tintColor
        // http://stackoverflow.com/a/30741478/2752598
        let tintColor = welcomeImage.tintColor
        welcomeImage.tintColor = nil
        welcomeImage.tintColor = tintColor
    }
    
    @IBAction func continueTapped() {
        let editProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        editProfileViewController.completeProfileMode = true
        navigationController?.setViewControllers([editProfileViewController], animated: true)
    }
}
