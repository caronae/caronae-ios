import UIKit
import SVProgressHUD
import InputMask
import YPImagePicker

class EditProfileViewController: UIViewController, NeighborhoodSelectionDelegate, MaskedTextFieldDelegateListener {
    
    // Profile
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var joinedDateLabel: UILabel!
    @IBOutlet weak var numDrivesLabel: UILabel!
    @IBOutlet weak var numRidesLabel: UILabel!
    @IBOutlet weak var fbButtonView: UIView!
    
    // Contacts
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    // Location
    @IBOutlet weak var neighborhoodButton: UIButton!
    
    // Car details
    @IBOutlet weak var carDetailsView: UIView!
    @IBOutlet weak var hasCarSwitch: UISwitch!
    @IBOutlet weak var carPlateTextField: UITextField!
    @IBOutlet weak var carModelTextField: UITextField!
    @IBOutlet weak var carColorTextField: UITextField!
    @IBOutlet weak var carDetailsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var user: User!
    var completeProfileMode = false
    
    var phoneMaskedDelegate: MaskedTextFieldDelegate!
    var carPlateMaskedDelegate: MaskedTextFieldDelegate!
    
    var loadingButton = UIBarButtonItem()
    
    var neighborhood = String() {
        didSet {
            if !neighborhood.isEmpty {
                neighborhoodButton.setTitle(neighborhood, for: .normal)
            } else {
                neighborhoodButton.setTitle("Bairro", for: .normal)
            }
        }
    }
    
    var photoURLString = String()
    var carDetailsHeightOriginal = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneMaskedDelegate = MaskedTextFieldDelegate(format: Caronae9PhoneNumberPattern)
        phoneMaskedDelegate.listener = self
        phoneTextField.delegate = phoneMaskedDelegate
        
        carPlateMaskedDelegate = MaskedTextFieldDelegate(format: CaronaeCarPlatePattern)
        carPlateMaskedDelegate.listener = self
        carPlateTextField.delegate = carPlateMaskedDelegate
        
        updateProfileFields()
        configureFacebookLoginButton()
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.startAnimating()
        loadingButton = UIBarButtonItem(customView: spinner)
        
        changePhotoButton.titleLabel?.textAlignment = .center
        
        if completeProfileMode {
            numDrivesLabel.text = "0"
            numRidesLabel.text = "0"
            title = "Cadastro"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }
    
    func configureFacebookLoginButton() {
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "user_friends"]
        loginButton.removeConstraints(loginButton.constraints)
        fbButtonView.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        fbButtonView.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[loginButton]|", options: .alignAllTop, metrics: nil, views: ["loginButton" : loginButton])
        )
        fbButtonView.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "|[loginButton]|", options: .alignAllTop, metrics: nil, views: ["loginButton" : loginButton])
        )
    }
    
    func updateProfileFields() {
        user = UserService.instance.user
        
        let joinedDateFormatter = DateFormatter()
        joinedDateFormatter.dateFormat = "MM/yyyy"
        joinedDateLabel.text = joinedDateFormatter.string(from: user.createdAt)
        
        nameLabel.text      = user.name
        courseLabel.text    = user.course.isEmpty ? user.profile : String(format: "%@ | %@", user.profile, user.course)
        numDrivesLabel.text = user.numDrives > -1 ? String(user.numDrives) : "-"
        numRidesLabel.text  = user.numRides > -1 ? String(user.numRides) : "-"
        
        emailTextField.text = user.email
        let phoneNumber = user.phoneNumber ?? ""
        phoneMaskedDelegate.put(text: phoneNumber, into: phoneTextField)
        
        neighborhood = user.location ?? ""
        
        hasCarSwitch.isOn = user.carOwner
        if !hasCarSwitch.isOn {
            carDetailsHeightOriginal = carDetailsHeight.constant
            carDetailsHeight.constant = 0
            carDetailsView.alpha = 0.0
        }
        
        let carPlate = user.carPlate ?? ""
        carPlateMaskedDelegate.put(text: carPlate, into: carPlateTextField)
        carModelTextField.text = user.carModel
        carColorTextField.text = user.carColor
        
        if let photoURLString = user.profilePictureURL, !photoURLString.isEmpty {
            self.photoURLString = photoURLString
            photoImageView.crn_setImage(with: URL(string: photoURLString))
        }
    }
    
    func generateUserFromView() -> User {
        let updatedUser = User()
        updatedUser.id = user.id
        updatedUser.name = user.name
        updatedUser.profile = user.profile
        updatedUser.course = user.course
        updatedUser.phoneNumber = phoneTextField.text?.onlyDigits
        updatedUser.email = emailTextField.text
        updatedUser.carOwner = hasCarSwitch.isOn
        updatedUser.carModel = hasCarSwitch.isOn ? carModelTextField.text : ""
        updatedUser.carPlate = hasCarSwitch.isOn ? carPlateTextField.text?.uppercased() : ""
        updatedUser.carColor = hasCarSwitch.isOn ? carColorTextField.text : ""
        updatedUser.location = neighborhood
        updatedUser.profilePictureURL = photoURLString
        
        return updatedUser
    }
    
    func saveProfile() {
        let updatedUser = generateUserFromView()
        showLoadingHUD(true)
        
        UserService.instance.updateUser(updatedUser, success: {
            self.showLoadingHUD(false)
            NSLog("User updated.")
            self.dismiss(animated: true, completion: nil)
        }) { error in
            self.showLoadingHUD(false)
            NSLog("Error saving profile: %@", error.localizedDescription)
            CaronaeAlertController.presentOkAlert(withTitle: "Erro atualizando perfil", message: "Ocorreu um erro salvando as alterações no seu perfil.")
        }
    }
    
    func isUserInputValid() -> Bool {
        guard let email = emailTextField.text, email.isValidEmail else {
            CaronaeAlertController.presentOkAlert(withTitle: "Dados incompletos", message: "Ops! Parece que o endereço de email que você inseriu não é válido.")
            return false
        }
        
        guard let phone = phoneTextField.text?.onlyDigits, phone.count == 12 else {
            CaronaeAlertController.presentOkAlert(withTitle: "Dados incompletos", message: "Ops! Parece que o telefone que você inseriu não é válido. Ele deve estar no formato (0XX) XXXXX-XXXX.")
            return false
        }
    
        guard !neighborhood.isEmpty else {
            CaronaeAlertController.presentOkAlert(withTitle: "Dados incompletos", message: "Ops! Parece que você esqueceu de preencher seu bairro.")
            return false
        }
        
        if hasCarSwitch.isOn && (carModelTextField.text!.isEmpty || carPlateTextField.text!.isEmpty || carColorTextField.text!.isEmpty) {
            CaronaeAlertController.presentOkAlert(withTitle: "Dados incompletos", message: "Ops! Parece que você marcou que tem um carro mas não preencheu os dados dele.")
            return false
        }
        
        if hasCarSwitch.isOn && !carPlateTextField.text!.isValidCarPlate {
            CaronaeAlertController.presentOkAlert(withTitle: "Dados incompletos", message: "Ops! Parece que preencheu incorretamente a placa do seu carro. Verifique se a preencheu no formato \"ABC-1234\".")
            return false
        }
    
        return true
    }
    
    
    // Mark: Zone selection method
    
    func hasSelected(neighborhoods: [String], inZone zone: String) {
        neighborhood = neighborhoods.first!
    }
    
    
    // MARK: IBActions
    
    @IBAction func didTapSaveButton() {
        view.endEditing(true)
    
        if isUserInputValid() {
            saveProfile()
        }
    }
    
    @IBAction func didTapCancelButton() {
        view.endEditing(true)
        var alert: CaronaeAlertController!
    
        if completeProfileMode {
            alert = CaronaeAlertController(title: "Cancelar cadastro?", message: "Você será deslogado do aplicativo e precisará entrar novamente com sua universidade.", preferredStyle: .alert)
            alert.addAction(SDCAlertAction(title: "Cont. editando", style: .cancel, handler: nil))
            alert.addAction(SDCAlertAction(title: "Sair", style: .destructive, handler: { _ in
                UserService.instance.signOut()
            }))
        } else {
            alert = CaronaeAlertController(title: "Cancelar edição do perfil?", message: "Quaisquer mudanças serão descartadas.", preferredStyle: .alert)
            alert.addAction(SDCAlertAction(title: "Cont. editando", style: .cancel, handler: nil))
            alert.addAction(SDCAlertAction(title: "Descartar", style: .destructive, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
        }
    
        alert.present(completion: nil)
    }
    
    @IBAction func didTapPhoto() {
        view.endEditing(true)
        
        let alert = UIAlertController(title: nil, message: "De onde deseja importar sua foto?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Usar foto do Facebook", style: .default, handler: { _ in
            self.importPhotoFromFacebook()
        }))
        alert.addAction(UIAlertAction(title: "Selecionar foto do celular", style: .default, handler: { _ in
            self.importPhotoFromDevice()
        }))
        alert.addAction(UIAlertAction(title: "Remover minha foto", style: .destructive, handler: { _ in
            NSLog("Removendo foto...")
            self.photoURLString = String()
            self.photoImageView.image = UIImage(named: CaronaePlaceholderProfileImage)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func hasCarSwitchChanged(_ sender: UISwitch) {
        view.endEditing(true)
        
        if sender.isOn {
            view.layoutIfNeeded()
            carDetailsHeight.constant = carDetailsHeightOriginal
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.carDetailsView.alpha = 1.0
            })
            
            // Scroll to bottom
            scrollView.scrollRectToVisible(CGRect(x: scrollView.contentSize.width - 1, y: self.scrollView.contentSize.height - 1, width: 1, height: 1), animated: true)
        } else {
            view.layoutIfNeeded()
            carDetailsHeightOriginal = carDetailsHeight.constant
            carDetailsHeight.constant = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.carDetailsView.alpha = 0.0
            })
        }
    }
    
    @IBAction func selectNeighborhoodTapped() {
        let selectionVC = NeighborhoodSelectionViewController(selectionType: .oneSelection)
        selectionVC.delegate = self
        navigationController?.show(selectionVC, sender: self)
    }
    
    
    // MARK: UITextField methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Automatically add prefix
        if textField == self.phoneTextField && self.phoneTextField.text!.isEmpty {
            phoneMaskedDelegate.put(text: "021", into: phoneTextField)
        }
    }
    
    
    // MARK: Etc
    
    func showLoadingHUD(_ loading: Bool) {
        navigationItem.rightBarButtonItem = loading ? self.loadingButton : self.saveButton
    }
    
    func importPhotoFromDevice() {
        var config = YPImagePickerConfiguration()
        config.library.onlySquare = true
        config.usesFrontCamera = true
        config.showsFilters = false
        config.albumName = "Caronaê"
        config.startOnScreen = .library
        config.hidesStatusBar = false
        config.targetImageSize = .cappedTo(size: 960)
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            guard let image = items.singlePhoto?.image else {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            NSLog("Importing profile picture from Device...")
            SVProgressHUD.show()
            UserService.instance.uploadPhotoFromDevice(image, success: { url in
                self.photoURLString = url
                self.photoImageView.crn_setImage(with: URL(string: self.photoURLString), completed: {
                    SVProgressHUD.dismiss()
                })
            }) { error in
                SVProgressHUD.dismiss()
                NSLog("Error uploading photo: %@", error.localizedDescription)
                CaronaeAlertController.presentOkAlert(withTitle: "Erro atualizando foto", message: "Não foi possível carregar sua foto de perfil.")
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    func importPhotoFromFacebook() {
        guard FBSDKAccessToken.current() != nil else {
            CaronaeAlertController.presentOkAlert(withTitle: "Conta do Facebook não autorizada.", message: "Você precisa ter feito login com sua conta do Facebook.")
            return
        }
    
        NSLog("Importing profile picture from Facebook...")
    
        SVProgressHUD.show()
        UserService.instance.getPhotoFromFacebook(success: { url in
            self.photoURLString = url
            self.photoImageView.crn_setImage(with: URL(string: self.photoURLString), completed: {
                SVProgressHUD.dismiss()
            })
        }) { error in
            SVProgressHUD.dismiss()
            NSLog("Error loading photo: %@", error.localizedDescription)
            CaronaeAlertController.presentOkAlert(withTitle: "Erro atualizando foto", message: "Não foi possível carregar sua foto de perfil do Facebook.")
        }
    }
}
