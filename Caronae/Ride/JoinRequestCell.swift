import UIKit

protocol JoinRequestDelegate: class {
    func handleAcceptedJoinRequest(of requestingUser: User, cell: JoinRequestCell)
    func answerJoinRequest(of requestingUser: User, hasAccepted accepted: Bool, cell: JoinRequestCell)
    func tappedUserDetails(of user: User)
}

class JoinRequestCell: UITableViewCell {

    weak var delegate: JoinRequestDelegate?
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userOccupationLabel: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    var requestingUser: User!
    var color: UIColor! {
        didSet {
            acceptButton.setTitleColor(color, for: .normal)
            acceptButton.layer.borderColor = color.cgColor
            userPhoto.layer.borderColor = color.cgColor
            tintColor = color
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let pictureTap = UITapGestureRecognizer(target: self, action: #selector(didTapUserDetails))
        userPhoto.addGestureRecognizer(pictureTap)
        
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(didTapUserDetails))
        userNameLabel.addGestureRecognizer(nameTap)
    }

    func configureCell(withUser user: User, andColor color: UIColor) {
        self.color = color
        requestingUser = user
        userNameLabel.text = user.name
        userOccupationLabel.text = user.occupation
        
        if let profilePictureURL = user.profilePictureURL, !profilePictureURL.isEmpty {
            userPhoto.crn_setImage(with: URL(string: profilePictureURL))
        }
    }
    
    func setButtonsEnabled(_ enabled: Bool) {
        acceptButton.isEnabled = enabled
        declineButton.isEnabled = enabled
        if enabled {
            acceptButton.alpha = 1.0
            declineButton.alpha = 1.0
        } else {
            acceptButton.alpha = 0.5
            declineButton.alpha = 0.5
        }
    }
    
    
    // MARK: IBActions
    
    @IBAction func didTapAcceptButton() {
        delegate?.handleAcceptedJoinRequest(of: requestingUser, cell: self)
    }
    
    @IBAction func didTapDeclineButton() {
        delegate?.answerJoinRequest(of: requestingUser, hasAccepted: false, cell: self)
    }
    
    @IBAction func didTapUserDetails() {
        delegate?.tappedUserDetails(of: requestingUser)
    }
}
