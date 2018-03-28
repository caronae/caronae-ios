import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileCourseLabel: UILabel!
    
    var photoURL: String!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = .white
        navigationItem.titleView = UIImageView(image: UIImage(named: "NavigationBarLogo"))
        
        updateProfileFields()
        
        NotificationCenter.default.addObserver(self, selector:#selector(updateProfileFields), name: .CaronaeDidUpdateUser, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = UserService.instance.user,
            let userPhotoURL = user.profilePictureURL,
            !userPhotoURL.isEmpty,
            userPhotoURL != photoURL {
            
            photoURL = userPhotoURL
            profileImageView.crn_setImage(with: URL(string: userPhotoURL))
        }
    }
    
    @objc func updateProfileFields() {
        guard let user = UserService.instance.user else {
            return
        }
        
        profileNameLabel.text = user.name
        profileCourseLabel.text = user.course.isEmpty ? user.profile : String(format: "%@ | %@", user.profile, user.course)
    }
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewProfile" {
            let vc = segue.destination as! ProfileViewController
            vc.user = UserService.instance.user
        } else if segue.identifier == "About" {
            let vc = segue.destination as! WebViewController
            vc.page = .aboutPage
        } else if segue.identifier == "TermsOfUse" {
            let vc = segue.destination as! WebViewController
            vc.page = .termsOfUsePage
        } else if segue.identifier == "FAQ" {
            let vc = segue.destination as! WebViewController
            vc.page = .FAQPage
        }
    }
    
    func openRidesHistory() {
        performSegue(withIdentifier: "RidesHistory", sender: nil)
    }
}
