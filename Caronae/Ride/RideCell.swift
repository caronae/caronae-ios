import UIKit

class RideCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrivalDateTimeLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var badgeLabel: UILabel!
    
    var ride: Ride!
    var color: UIColor! {
        didSet {
            titleLabel.textColor = color
            arrivalDateTimeLabel.textColor = color
            driverNameLabel.textColor = color
            photo.layer.borderColor = color.cgColor
            tintColor = color
        }
    }
    
    var badgeCount: Int! {
        didSet {
            if badgeCount > 0 {
                badgeLabel.text = String(badgeCount)
                badgeLabel.isHidden = false
            } else {
                badgeLabel.isHidden = true
            }
        }
    }
    
    let dateFormatter = DateFormatter()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        dateFormatter.dateFormat = "HH:mm | E | dd/MM"
    }
    
    /// Configures the cell with a Ride object, updating the cell's labels and style accordingly.
    ///
    /// - parameter ride: A Ride object.
    func configureCell(with ride: Ride) {
        configureBasicCell(with: ride)
        accessoryType = .disclosureIndicator
        if ride.going {
            arrivalDateTimeLabel.text = String(format: "Chegando às %@", dateString())
        } else {
            arrivalDateTimeLabel.text = String(format: "Saindo às %@", dateString())
        }
    }
    
    /// Configures the cell with a Ride object which belongs to a user's ride history, updating the cell's labels and style accordingly.
    ///
    /// - parameter ride: A Ride object.
    func configureHistoryCell(with ride: Ride) {
        configureBasicCell(with: ride)
        accessoryType = .none
        if ride.going {
            arrivalDateTimeLabel.text = String(format: "Chegou às %@", dateString())
        } else {
            arrivalDateTimeLabel.text = String(format: "Saiu às %@", dateString())
        }
    }
    
    func configureBasicCell(with ride: Ride) {
        self.ride = ride
        titleLabel.text = ride.title.uppercased()
        driverNameLabel.text = ride.driver.shortName
        
        updatePhoto()
        color = PlaceService.instance.color(forZone: ride.region)
        
        badgeLabel.isHidden = true
    }
    
    func dateString() -> String {
        return dateFormatter.string(from: ride.date).capitalized(after: "|")
    }
    
    func updatePhoto() {
        if let profilePictureURL = ride.driver.profilePictureURL, !profilePictureURL.isEmpty {
            photo.crn_setImage(with: URL(string: profilePictureURL))
        } else {
            photo.image = UIImage(named: CaronaePlaceholderProfileImage)
        }
    }
}
