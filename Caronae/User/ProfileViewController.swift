import UIKit
import InputMask

class ProfileViewController: UIViewController, UICollectionViewDataSource {
    
    // ID
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneButton: UIButton!
    
    // Mutual friends
    @IBOutlet weak var mutualFriendsView: UIView!
    @IBOutlet weak var mutualFriendsCollectionView: UICollectionView!
    @IBOutlet weak var mutualFriendsLabel: UILabel!
    
    // Numbers
    @IBOutlet weak var joinedDateLabel: UILabel!
    @IBOutlet weak var numDrivesLabel: UILabel!
    @IBOutlet weak var numRidesLabel: UILabel!
    
    // Car details
    @IBOutlet weak var carDetailsView: UIView!
    @IBOutlet weak var carPlateLabel: UILabel!
    @IBOutlet weak var carModelLabel: UILabel!
    @IBOutlet weak var carColorLabel: UILabel!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var signoutButton: UIButton!
    @IBOutlet weak var reportView: UIView!
    
    var user: User!
    
    var mutualFriends = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateProfileFields()
        
        if UserService.instance.user == self.user {
            NotificationCenter.default.addObserver(self, selector:#selector(updateProfileFields), name: .CaronaeDidUpdateUser, object: nil)
        }
        
        // Add gesture recognizer to phoneButton for longpress
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressPhoneButton))
        phoneButton.addGestureRecognizer(longPressGesture)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateProfileFields() {
        guard let currentUser = UserService.instance.user else {
            return
        }
        
        if currentUser.id == user.id {
            self.title = "Meu Perfil"
            
            if user.carOwner {
                carPlateLabel.text = user.carPlate
                carModelLabel.text = user.carModel
                carColorLabel.text = user.carColor
            } else {
                carPlateLabel.text = "-"
                carModelLabel.text = "-"
                carColorLabel.text = "-"
            }
            
            DispatchQueue.main.async {
                self.mutualFriendsView.removeFromSuperview()
                self.reportView.removeFromSuperview()
            }
        } else {
            self.title = user.name
            self.navigationItem.rightBarButtonItem = nil
            DispatchQueue.main.async {
                self.carDetailsView.removeFromSuperview()
                self.signoutButton.removeFromSuperview()
            }
            updateMutualFriends()
        }
        
        if let userCreateAt = user.createdAt {
            let joinedDateFormatter = DateFormatter()
            joinedDateFormatter.dateFormat = "MM/yyyy"
            joinedDateLabel.text = joinedDateFormatter.string(from: userCreateAt)
        }
        
        nameLabel.text      = user.name
        courseLabel.text    = user.course.isEmpty ? user.profile : String(format: "%@ | %@", user.profile, user.course)
        numDrivesLabel.text = user.numDrives > -1 ? String(user.numDrives) : "-"
        numRidesLabel.text  = user.numRides > -1 ? String(user.numRides) : "-"
        
        if let phoneNumber = user.phoneNumber, !phoneNumber.isEmpty {
            let phoneMask = try! Mask(format: Caronae9PhoneNumberPattern)
            let result = phoneMask.apply(toText: CaretString(string: phoneNumber, caretPosition: phoneNumber.endIndex))
            let formattedPhoneNumber = result.formattedText.string
            phoneButton.setTitle(formattedPhoneNumber, for: .normal)
        } else {
            DispatchQueue.main.async {
                self.phoneView.removeFromSuperview()
            }
        }
        
        if let profilePictureURL = user.profilePictureURL, !profilePictureURL.isEmpty {
            self.profileImage.crn_setImage(with: URL(string: profilePictureURL))
        }
        
        updateRidesOfferedCount()
    }
    
    func updateRidesOfferedCount() {
        UserService.instance.ridesCountForUser(withID: user.id, success: { offeredCount, takenCount in
            self.numDrivesLabel.text = String(offeredCount)
            self.numRidesLabel.text = String(takenCount)
        }) { error in
            NSLog("Error reading history count for user: %@", error.localizedDescription)
        }
    }
    
    func updateMutualFriends() {
        UserService.instance.mutualFriendsForUser(withFacebookID: user.facebookID, success: { mutualFriends, totalCount in
            self.mutualFriends = mutualFriends
            self.mutualFriendsCollectionView.reloadData()
            
            if totalCount > 0 {
                self.mutualFriendsLabel.text = String(format: "Amigos em comum: %ld no total e %ld no Caronaê", totalCount, mutualFriends.count)
            } else {
                self.mutualFriendsLabel.text = "Amigos em comum: 0"
            }
        }) { error in
            NSLog("Error loading mutual friends for user: %@", error.localizedDescription)
        }
    }
    
    
    // MARK: IBActions
    
    @objc func didLongPressPhoneButton() {
        let alert = PhoneNumberAlert().actionSheet(view: self, buttonText: phoneButton.titleLabel!.text!, user: user)
        self.present(alert!, animated: true, completion: nil)
    }
    
    @IBAction func didTapPhoneButton() {
        guard let phoneNumber = user.phoneNumber else {
            return
        }
        
        let phoneNumberURLString = String(format: "telprompt://%@", phoneNumber)
        UIApplication.shared.openURL(URL(string: phoneNumberURLString)!)
    }
    
    @IBAction func didTapLogoutButton() {
        let alert = CaronaeAlertController(title: "Você deseja mesmo sair da sua conta?", message: nil, preferredStyle: .alert)
        alert?.addAction(SDCAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert?.addAction(SDCAlertAction(title: "Sair", style: .destructive, handler: { _ in
            UserService.instance.signOut()
        }))
        
        alert?.present(completion: nil)
    }
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReportUser" {
            let falaeVC = segue.destination as! FalaeViewController
            falaeVC.reportedUser = user
        }
    }
    
    
    // MARK: Collection methods (Mutual friends)
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mutualFriends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Friend Cell", for: indexPath) as! RiderCell
        let user = mutualFriends[indexPath.row]
        cell.configure(with: user)
        
        return cell
    }
}
