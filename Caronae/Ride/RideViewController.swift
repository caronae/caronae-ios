import Foundation
import SVProgressHUD
import SHSPhoneComponent

class RideViewController: UIViewController, JoinRequestDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    // Ride info
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var referenceLabel: UILabel!
    @IBOutlet weak var driverPhoto: UIImageView!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverCourseLabel: UILabel!
    @IBOutlet weak var mutualFriendsLabel: UILabel!
    @IBOutlet weak var driverMessageLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var carDetailsView: UIView!
    @IBOutlet weak var carPlateLabel: UILabel!
    @IBOutlet weak var carModelLabel: UILabel!
    @IBOutlet weak var carColorLabel: UILabel!
    @IBOutlet weak var noRidersLabel: UILabel!
    
    // Assets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var ridersView: UIView!
    @IBOutlet weak var mutualFriendsView: UIView!
    @IBOutlet weak var mutualFriendsCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var finishRideView: UIView!
    @IBOutlet weak var shareRideView: UIView!
    @IBOutlet weak var ridersCollectionView: UICollectionView!
    @IBOutlet weak var mutualFriendsCollectionView: UICollectionView!
    @IBOutlet weak var clockIcon: UIImageView!
    @IBOutlet weak var carIconPlate: UIImageView!
    @IBOutlet weak var carIconModel: UIImageView!
    @IBOutlet weak var requestsTable: UITableView!
    @IBOutlet weak var requestsTableHeight: NSLayoutConstraint!
    
    // Buttons
    @IBOutlet weak var requestRideButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var finishRideButton: UIButton!
    @IBOutlet weak var shareRideButton: UIButton!
    
    var ride: Ride!
    var shouldOpenChatWindow = false
    var rideIsFull = false
    
    var requesters = [User]()
    var mutualFriends = [User]()
    var selectedUser: User?
    var color: UIColor! {
        didSet {
            headerView.backgroundColor = color
            clockIcon.tintColor = color
            dateLabel.textColor = color
            driverPhoto.layer.borderColor = color?.cgColor
            carIconPlate.tintColor = color
            carIconModel.tintColor = color
            finishRideButton.layer.borderColor = color?.cgColor
            finishRideButton.tintColor = color
            shareRideButton.layer.borderColor = color?.cgColor
            shareRideButton.tintColor = color
            requestRideButton.backgroundColor = color
            finishRideButton.setTitleColor(color, for: .normal)
            shareRideButton.setTitleColor(color, for: .normal)
        }
    }
    
    let CaronaeRequestButtonStateNew              = "PEGAR CARONA"
    let CaronaeRequestButtonStateAlreadyRequested = "    SOLICITAÇÃO ENVIADA    "
    let CaronaeRequestButtonStateFullRide         = "       CARONA CHEIA       "
    let CaronaeFinishButtonStateAlreadyFinished   = "  Carona concluída"
    
    class func instance(for ride: Ride) -> RideViewController {
        let rideVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RideViewController") as! RideViewController
        rideVC.ride = ride
        return rideVC
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load ride from realm database if available
        self.loadRealmRide()
        
        self.clearNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(updateChatButtonBadge), name: .CaronaeDidUpdateNotifications, object: nil)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm | E | dd/MM"
        let dateString = dateFormatter.string(from: ride.date).capitalized(after: "|")
        
        titleLabel.text = ride.title.uppercased()
        dateLabel.text = ride.going ? String(format: "Chegando às %@", dateString) : String(format: "Saindo às %@", dateString)
        
        driverNameLabel.text = ride.driver.name
        driverCourseLabel.text = ride.driver.course.isEmpty ? ride.driver.profile : String(format: "%@ | %@", ride.driver.profile, ride.driver.course)
        
        referenceLabel.text = ride.place.isEmpty ? "---" : ride.place
        routeLabel.text = ride.route.isEmpty ? "---" : ride.route.replacingOccurrences(of: ", ", with: "\n").replacingOccurrences(of: ",", with: "\n")
        driverMessageLabel.text = ride.notes.isEmpty ? "---" : ride.notes
        
        if let profilePictureURL = ride.driver.profilePictureURL, !profilePictureURL.isEmpty {
            driverPhoto.crn_setImage(with: URL(string: profilePictureURL))
        }
        
        color = PlaceService.instance.color(forZone: ride.region)
        
        let requestCellNib = UINib(nibName: String(describing: JoinRequestCell.self), bundle: nil)
        requestsTable.register(requestCellNib, forCellReuseIdentifier: "Request Cell")
        requestsTable.dataSource = self
        requestsTable.delegate = self
        requestsTable.rowHeight = 95.0
        requestsTableHeight.constant = 0
        
        if !ride.date.isInTheFuture() {
            DispatchQueue.main.async {
                self.shareRideView.removeFromSuperview()
            }
        }
        
        // If the user is the driver of the ride, load pending join requests and hide 'join' button
        if self.userIsDriver() {
            self.loadJoinRequests()
            self.updateChatButtonBadge()
            
            DispatchQueue.main.async {
                self.requestRideButton.removeFromSuperview()
                self.mutualFriendsView.removeFromSuperview()
                self.phoneView.removeFromSuperview()
                
                if !self.ride.isActive || self.ride.date.isInTheFuture() {
                    self.finishRideView.removeFromSuperview()
                }
            }
            
            // Car details
            let user = UserService.instance.user!
            carPlateLabel.text = user.carPlate?.uppercased()
            carModelLabel.text = user.carModel
            carColorLabel.text = user.carColor
            
            // If the riders aren't provided then hide the riders view
            if ride.riders.isEmpty {
                DispatchQueue.main.async {
                    self.ridersView.removeFromSuperview()
                }
            }
        }
        // If the user is already a rider, hide 'join' button
        else if self.userIsRider() {
            self.updateChatButtonBadge()
            
            DispatchQueue.main.async {
                self.requestRideButton.removeFromSuperview()
                self.finishRideView.removeFromSuperview()
            }
            
            cancelButton.setTitle("DESISTIR", for: .normal)
            let phoneFormatter = SHSPhoneNumberFormatter()
            phoneFormatter.setDefaultOutputPattern(Caronae8PhoneNumberPattern)
            phoneFormatter.addOutputPattern(Caronae9PhoneNumberPattern, forRegExp: "[0-9]{12}\\d*$")
            let result = phoneFormatter.values(for: ride.driver.phoneNumber)
            let formattedPhoneNumber = result!["text"] as! String
            phoneButton.setTitle(formattedPhoneNumber, for: .normal)
            
            // Car details
            carPlateLabel.text = ride.driver.carPlate?.uppercased()
            carModelLabel.text = ride.driver.carModel
            carColorLabel.text = ride.driver.carColor
            
            self.updateMutualFriends()
        }
        // If the user is not related to the ride, hide 'cancel' button, car details view, riders view
        else {
            DispatchQueue.main.async {
                self.cancelButton.removeFromSuperview()
                self.phoneView.removeFromSuperview()
                self.carDetailsView.removeFromSuperview()
                self.finishRideView.removeFromSuperview()
                self.ridersView.removeFromSuperview()
            }
            
            // Update the state of the join request button if the user has already requested to join
            if RideService.instance.hasRequestedToJoinRide(withID: ride.id) {
                requestRideButton.isEnabled = false
                requestRideButton.setTitle(CaronaeRequestButtonStateAlreadyRequested, for: .normal)
            } else if rideIsFull {
                requestRideButton.isEnabled = false
                requestRideButton.setTitle(CaronaeRequestButtonStateFullRide, for: .normal)
                rideIsFull = false
            } else {
                requestRideButton.isEnabled = true
                requestRideButton.setTitle(CaronaeRequestButtonStateNew, for: .normal)
            }
            self.updateMutualFriends()
        }
        
        // Add gesture recognizer to phoneButton for longpress
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressPhoneButton))
        phoneButton.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldOpenChatWindow {
            openChatWindow()
            shouldOpenChatWindow = false
        }
    }
    
    func updateMutualFriends() {
        UserService.instance.mutualFriendsForUser(withFacebookID: ride.driver.facebookID, success: { mutualFriends, totalCount in
            if !mutualFriends.isEmpty {
                self.mutualFriends = mutualFriends
                self.mutualFriendsCollectionHeight.constant = 40.0
                self.mutualFriendsView.layoutIfNeeded()
                self.mutualFriendsCollectionView.reloadData()
            }

            self.mutualFriendsLabel.text = totalCount > 0 ? String(format: "Amigos em comum: %ld no total e %ld no Caronaê", totalCount, mutualFriends.count) : "Amigos em comum: 0"
        }, error: { error in
            NSLog("Error loading mutual friends for user: %@", error.localizedDescription)
        })
    }
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewProfile" {
            let profileVC = segue.destination as! ProfileViewController
            profileVC.user = selectedUser
        }
    }
    
    @objc func openChatWindow() {
        let chatVC = ChatViewController(ride: ride, color: color)
        navigationController?.show(chatVC, sender: self)
    }
    
    
    // MARK: IBActions
    
    @objc func didLongPressPhoneButton() {
        let alert = PhoneNumberAlert().actionSheet(view: self, buttonText: phoneButton.titleLabel!.text!, user: ride.driver)
        self.present(alert!, animated: true, completion: nil)
    }
    
    @IBAction func didTapPhoneButton(_ sender: Any) {
        guard let phoneNumber = ride.driver.phoneNumber else {
            return
        }
        
        let phoneNumberURLString = String(format: "telprompt://%@", phoneNumber)
        UIApplication.shared.openURL(URL(string: phoneNumberURLString)!)
    }
    
    @IBAction func didTapRequestRide(_ sender: UIButton) {
        let alert = CaronaeAlertController(title: "Deseja mesmo solicitar a carona?",
                                           message: "Ao confirmar, o motorista receberá uma notificação e poderá aceitar ou recusar a carona.",
                                           preferredStyle: .alert)
        alert?.addAction(SDCAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert?.addAction(SDCAlertAction(title: "Solicitar", style: .recommended, handler: { _ in
            self.requestJoinRide()
        }))
        alert?.present(completion: nil)
    }
    
    @IBAction func viewUserProfile(_ sender: Any) {
        selectedUser = User(value: ride.driver)
        if !self.userIsDriver() && !self.userIsRider() {
            // Hide driver's phone number
            selectedUser?.phoneNumber = nil
        }
        performSegue(withIdentifier: "ViewProfile", sender: self)
    }
    
    @IBAction func didTapCancelRide(_ sender: Any) {
        let alert = CaronaeAlertController(title: "Deseja mesmo desistir da carona?",
                                           message: "Você é livre para cancelar caronas caso não possa participar, mas é importante fazer isso com responsabilidade. Caso haja outros usuários na carona, eles serão notificados.",
                                           preferredStyle: .alert)
        alert?.addAction(SDCAlertAction(title: "Voltar", style: .cancel, handler: nil))
        alert?.addAction(SDCAlertAction(title: "Desistir", style: .destructive, handler: { _ in
            self.cancelRide()
        }))
        alert?.present(completion: nil)
    }
    
    @IBAction func didTapFinishRide(_ sender: Any) {
        let alert = CaronaeAlertController(title: "E aí? Correu tudo bem?",
                                           message: "Caso você tenha tido algum problema com a carona, use o Falaê para entrar em contato conosco.",
                                           preferredStyle: .alert)
        alert?.addAction(SDCAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert?.addAction(SDCAlertAction(title: "Concluir", style: .recommended, handler: { _ in
            self.finishRide()
        }))
        alert?.present(completion: nil)
    }
    
    @IBAction func didTapShareRide(_ sender: Any) {
        let rideTitle = String(format: "Carona: %@", ride.title)
        let rideLink = URL(string: String(format: "https://caronae.com.br/carona/%ld", ride.id))!
        let rideToShare = [rideTitle, dateLabel.text!, rideLink] as [Any]
        
        let activityVC = UIActivityViewController(activityItems: rideToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [.addToReadingList]
        
        present(activityVC, animated: true, completion: nil)
    }
    
    
    // Mark: Ride operations

    func cancelRide() {
        if self.userIsDriver() && ride.isRoutine {
            let alert = UIAlertController(title: "Esta carona pertence a uma rotina.", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Desistir somente desta", style: .destructive, handler: { _ in
                self.leaveRide()
            }))
            alert.addAction(UIAlertAction(title: "Desistir da rotina", style: .destructive, handler: { _ in
                self.deleteRoutine()
            }))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            leaveRide()
        }
    }
    
    func leaveRide() {
        NSLog("Requesting to leave/cancel ride %ld", ride.id)
        
        cancelButton.isEnabled = false
        SVProgressHUD.show()
        
        RideService.instance.leaveRide(withID: ride.id, success: {
            SVProgressHUD.dismiss()
            NSLog("User left the ride.")
            self.navigationController?.popViewController(animated: true)
        }, error: { error in
            NSLog("Error leaving/cancelling ride: %@", error.localizedDescription)
            SVProgressHUD.dismiss()
            self.cancelButton.isEnabled = true
            CaronaeAlertController.presentOkAlert(withTitle: "Algo deu errado.", message: String(format: "Não foi possível cancelar sua carona. (%@)", error.localizedDescription))
        })
    }
    
    func finishRide() {
        NSLog("Requesting to finish ride %ld", ride.id)
        
        finishRideButton.isEnabled = false
        SVProgressHUD.show()
        
        RideService.instance.finishRide(withID: ride.id, success: {
            SVProgressHUD.dismiss()
            NSLog("User finished the ride.")
            self.navigationController?.popViewController(animated: true)
        }, error: { error in
            NSLog("Error finishing ride: %@", error.localizedDescription)
            SVProgressHUD.dismiss()
            self.finishRideButton.isEnabled = true
            CaronaeAlertController.presentOkAlert(withTitle: "Algo deu errado.", message: String(format: "Não foi possível concluir sua carona. (%@)", error.localizedDescription))
        })
    }
    
    
    // MARK: Join request methods
    
    func requestJoinRide() {
        NSLog("Requesting to join ride %ld", ride.id)
        
        requestRideButton.isEnabled = false
        SVProgressHUD.show()
        
        RideService.instance.requestJoinOnRide(ride, success: {
            SVProgressHUD.dismiss()
            NSLog("Done requesting ride.")
            self.requestRideButton.setTitle(self.CaronaeRequestButtonStateAlreadyRequested, for: .normal)
        }, error: { error in
            NSLog("Error requesting to join ride: %@", error.localizedDescription)
            SVProgressHUD.dismiss()
            self.requestRideButton.isEnabled = true
            CaronaeAlertController.presentOkAlert(withTitle: "Algo deu errado.", message: String(format: "Não foi possível solicitar a carona. (%@)", error.localizedDescription))
        })
    }
    
    func loadJoinRequests() {
        RideService.instance.getRequestersForRide(withID: ride.id, success: { users in
            self.requesters = users
            if !self.requesters.isEmpty {
                self.requestsTable.reloadData()
                self.adjustHeightOfTableview()
            }
        }, error: { error in
            NSLog("Error loading join requests for ride %lu: %@", self.ride.id, error.localizedDescription)
            CaronaeAlertController.presentOkAlert(withTitle: "Algo deu errado.", message: String(format: "Não foi possível carregar as solicitações da sua carona. (%@)", error.localizedDescription))
        })
    }
    
    func handleAcceptedJoinRequest(_ user: User, cell: JoinRequestCell) {
        cell.setButtonsEnabled(false)
        
        if ride.availableSlots == 1 && requesters.count > 1 {
            let alert = CaronaeAlertController(title: String(format: "Deseja mesmo aceitar %@?", user.firstName),
                                               message: "Ao aceitar, sua carona estará cheia e você irá recusar os outros caronistas.",
                                               preferredStyle: .alert)
            alert?.addAction(SDCAlertAction(title: "Cancelar", style: .cancel, handler: { _ in
                cell.setButtonsEnabled(true)
            }))
            alert?.addAction(SDCAlertAction(title: "Aceitar", style: .recommended, handler: { _ in
                self.answerJoinRequest(user, hasAccepted: true, cell: cell)
            }))
            alert?.present(completion: nil)
        } else {
            self.answerJoinRequest(user, hasAccepted: true, cell: cell)
        }
    }
    
    func answerJoinRequest(_ requestingUser: User, hasAccepted: Bool, cell: JoinRequestCell) {
        cell.setButtonsEnabled(false)
        
        RideService.instance.answerRequestOnRide(withID: ride.id, fromUser: requestingUser, accepted: hasAccepted, success: {
            NSLog("Request for user %@ was %@", requestingUser.name, hasAccepted ? "accepted" : "not accepted")
            self.removeJoinRequest(requestingUser: requestingUser)
            if hasAccepted {
                self.ridersCollectionView.reloadData()
                self.removeAllJoinRequestIfNeeded()
            }
        }, error: { error in
            NSLog("Error accepting join request: %@", error.localizedDescription)
            cell.setButtonsEnabled(true)
        })
    }
    
    func removeAllJoinRequestIfNeeded() {
        if ride.availableSlots == 0 {
            for requester in requesters {
                self.removeJoinRequest(requestingUser: requester)
            }
        }
    }
    
    func removeJoinRequest(requestingUser: User) {
        requestsTable.beginUpdates()
        let index = requesters.index(of: requestingUser)!
        requestsTable.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        requesters.remove(at: index)
        requestsTable.endUpdates()
        self.adjustHeightOfTableview()
        self.clearNotificationOfJoinRequest(from: requestingUser.id)
    }
    
    func tappedUserDetails(forRequest user: User!) {
        self.selectedUser = user;
        performSegue(withIdentifier: "ViewProfile", sender: self)
    }
    
    
    // MARK: Table methods (Join requests)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requesters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Request Cell", for: indexPath) as! JoinRequestCell
        
        cell.delegate = self
        cell.configureCell(with: self.requesters[indexPath.row])
        cell.color = self.color
        
        return cell
    }
    
    func adjustHeightOfTableview() {
        self.view.layoutIfNeeded()
        let height = CGFloat(self.requesters.count) * self.requestsTable.rowHeight
        self.requestsTableHeight.constant = height
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    // MARK: Collection methods (Riders, Mutual friends)
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == ridersCollectionView {
            
            // Show message if there is no riders
            if ride.riders.isEmpty {
                noRidersLabel.isHidden = false
            } else {
                noRidersLabel.isHidden = true
            }
            
            return ride.riders.count
        } else {
            return mutualFriends.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: RiderCell!
        var user: User!
        
        if collectionView == ridersCollectionView {
            user = ride.riders[indexPath.row]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Rider Cell", for: indexPath) as! RiderCell
        } else {
            user = self.mutualFriends[indexPath.row]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Friend Cell", for: indexPath) as! RiderCell
        }
        
        cell.configure(with: user)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if collectionView == ridersCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as! RiderCell
            self.selectedUser = cell.user
            
            performSegue(withIdentifier: "ViewProfile", sender: self)
        }
    }
    
}
