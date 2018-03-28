import UIKit

class RiderCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var user: User!
    
    func configure(with user: User) {
        self.user = user
        if nameLabel != nil {
            nameLabel.text = user.firstName
        }
        if let profilePictureURL = user.profilePictureURL, !profilePictureURL.isEmpty {
            photo.crn_setImage(with: URL(string: profilePictureURL))
        }
    }
}
