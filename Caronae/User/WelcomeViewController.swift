import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!

    convenience init() {
        self.init(nibName: "WelcomeViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        let user = UserService.instance.user!
        titleLabel.text = "Olá, " + user.firstName + "!"
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "NavigationBarLogo"))
    }
    
    @IBAction func continueTapped() {
        let editProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        editProfileViewController.completeProfileMode = true
        navigationController?.pushViewController(editProfileViewController, animated: true)
    }
}
