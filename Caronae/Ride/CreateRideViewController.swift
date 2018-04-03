import UIKit
import SVProgressHUD
import ActionSheetPicker_3_0

class CreateRideViewController: UIViewController, NeighborhoodSelectionDelegate, HubSelectionDelegate {

    @IBOutlet weak var neighborhoodButton: UIButton!
    @IBOutlet weak var reference: UITextField!
    @IBOutlet weak var route: UITextField!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var routineSwitch: UISwitch!
    @IBOutlet weak var slotsStepper: UIStepper!
    @IBOutlet weak var slotsLabel: UILabel!
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var createRideButton: UIButton!
    
    @IBOutlet weak var routinePatternView: UIView!
    @IBOutlet weak var routinePatternHeight: NSLayoutConstraint!
    
    @IBOutlet weak var routineDuration2MonthsButton: UIButton!
    @IBOutlet weak var routineDuration3MonthsButton: UIButton!
    @IBOutlet weak var routineDuration4MonthsButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    
    var routinePatternHeightOriginal: CGFloat?
    var notesPlaceholder: String?
    var notesTextColor: UIColor?
    
    var weekDays = [String]()
    var routineDurationMonths: Int?
    var selectedDate: Date? {
        didSet {
            let dateString = dateFormatter.string(from: selectedDate!)
            dateButton.setTitle(dateString, for: .normal)
        }
    }
    
    let userDefaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    
    var selectedNeighborhood = String() {
        didSet {
            let selection = selectedNeighborhood.isEmpty ? "Bairro" : selectedNeighborhood
            self.neighborhoodButton.setTitle(selection, for: .normal)
        }
    }

    var selectedHub = String() {
        didSet {
            let selection = selectedHub.isEmpty ? "Centro Universitário" : selectedHub
            self.centerButton.setTitle(selection, for: .normal)
        }
    }
    
    var selectedZone = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserHasCar()
        
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        selectedDate = max(Date.nextHour, Date.currentTimePlus(minutes: 5))
        routineDurationMonths = 2
        
        segmentedControl.layer.cornerRadius = 8.0
        segmentedControl.layer.borderColor = UIColor(white: 0.690, alpha: 1.0).cgColor
        segmentedControl.layer.borderWidth = 2.0
        segmentedControl.layer.masksToBounds = true
        
        // Configure direction titles according to institution
        segmentedControl.setTitle(PlaceService.Institution.goingLabel, forSegmentAt: 0)
        segmentedControl.setTitle(PlaceService.Institution.leavingLabel, forSegmentAt: 1)
        
        notes.layer.cornerRadius = 8.0
        notes.layer.borderColor = UIColor(white: 0.902, alpha: 1.0).cgColor
        notes.layer.borderWidth = 2.0
        notes.textContainerInset = UIEdgeInsetsMake(10, 5, 5, 5)
        notes.delegate = self
        notesPlaceholder = notes.text
        notesTextColor = notes.textColor
        
        if let lastOfferedRide      = userDefaults.dictionary(forKey: CaronaePreferenceLastOfferedRide.key) {
            if let lastZone         = lastOfferedRide[CaronaePreferenceLastOfferedRide.zone] as? String,
               let lastNeighborhood = lastOfferedRide[CaronaePreferenceLastOfferedRide.neighborhood] as? String,
               let lastPlace        = lastOfferedRide[CaronaePreferenceLastOfferedRide.place] as? String,
               let lastRoute        = lastOfferedRide[CaronaePreferenceLastOfferedRide.route] as? String,
               let lastSlots        = lastOfferedRide[CaronaePreferenceLastOfferedRide.slots] as? Double,
               let lastDescription  = lastOfferedRide[CaronaePreferenceLastOfferedRide.description] as? String {
                selectedZone = lastZone
                selectedNeighborhood = lastNeighborhood
                reference.text = lastPlace
                route.text = lastRoute
                slotsStepper.value = lastSlots
                if !lastDescription.isEmpty {
                    notes.text = lastDescription
                    notes.textColor = .black
                }
            }
            
            if let lastHubGoing = lastOfferedRide[CaronaePreferenceLastOfferedRide.hubGoing] as? String {
                selectedHub = lastHubGoing
            }
        }
        
        slotsLabel.text = String(format: "%.f", slotsStepper.value)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.endEditing(true)
    }
    
    func checkIfUserHasCar() {
        if let user = UserService.instance.user, !user.carOwner {
            CaronaeAlertController.presentOkAlert(withTitle: "Você possui carro?", message: "Parece que você marcou no seu perfil que não possui um carro.Para criar uma carona, preencha os dados do seu carro no seu perfil.", handler: {
                self.didTapCancelButton(self)
            })
        }
    }
    
    func generateRideFromView() -> Ride {
        let description = notes.text == notesPlaceholder ? "" : notes.text
        let going = self.segmentedControl.selectedSegmentIndex == 0
        
        let ride = Ride()
        ride.region = selectedZone
        ride.neighborhood = selectedNeighborhood
        ride.place = reference.text
        ride.route = route.text
        ride.hub = selectedHub
        ride.notes = description;
        ride.going = going;
        ride.date = selectedDate
        ride.slots = Int(slotsStepper.value)
        
        // Routine fields
        if routineSwitch.isOn {
            let weekDaysString = weekDays.sorted().joined(separator: ",")
            ride.weekDays = weekDaysString
            
            // Calculate final date for event based on the selected duration
            var dateComponents = DateComponents()
            dateComponents.month = routineDurationMonths
            let repeatsUntilDate = Calendar.current.date(byAdding: dateComponents, to: ride.date)
            ride.repeatsUntil = repeatsUntilDate;
        }
        
        return ride;
    }
    
    func savePreset(ride: Ride) {
        let lastRidePresets = userDefaults.dictionary(forKey: CaronaePreferenceLastOfferedRide.key)
        
        var newPresets: [String : Any] = [CaronaePreferenceLastOfferedRide.zone         : ride.region,
                                          CaronaePreferenceLastOfferedRide.neighborhood : ride.neighborhood,
                                          CaronaePreferenceLastOfferedRide.place        : ride.place,
                                          CaronaePreferenceLastOfferedRide.route        : ride.route,
                                          CaronaePreferenceLastOfferedRide.slots        : ride.slots,
                                          CaronaePreferenceLastOfferedRide.description  : ride.notes]
        
        if ride.going {
            newPresets[CaronaePreferenceLastOfferedRide.hubGoing] = ride.hub
            if let lastHubReturning = lastRidePresets?[CaronaePreferenceLastOfferedRide.hubReturning] {
                newPresets[CaronaePreferenceLastOfferedRide.hubReturning] = lastHubReturning
            }
        } else {
            newPresets[CaronaePreferenceLastOfferedRide.hubReturning] = ride.hub
            if let lastHubGoing = lastRidePresets?[CaronaePreferenceLastOfferedRide.hubGoing] {
                newPresets[CaronaePreferenceLastOfferedRide.hubGoing] = lastHubGoing
            }
        }
        
        userDefaults.set(newPresets, forKey: CaronaePreferenceLastOfferedRide.key)
    }
    
    func createRide(ride: Ride) {
        SVProgressHUD.show()
        createRideButton.isEnabled = false
        
        savePreset(ride: ride)
        
        RideService.instance.createRide(ride, success: {
            SVProgressHUD.dismiss()
            lastAllRidesUpdate = Date.distantPast
            self.dismiss(animated: true, completion: nil)
        }, error: { error in
            SVProgressHUD.dismiss()
            self.createRideButton.isEnabled = true
            
            NSLog("Error creating ride: %@", error.localizedDescription)
            
            CaronaeAlertController.presentOkAlert(withTitle: "Não foi possível criar a carona.", message: error.localizedDescription)
        })
    }
    
    @IBAction func didTapCreateButton(_ sender: Any) {
        self.view.endEditing(true)
        
        // Check if the user selected the location and hub
        if selectedZone.isEmpty || selectedNeighborhood.isEmpty || selectedHub.isEmpty {
            CaronaeAlertController.presentOkAlert(withTitle: "Dados incompletos", message: "Ops! Parece que você esqueceu de preencher o local da sua carona.")
            return
        }
        
        // Check if the user has selected the routine details
        if routineSwitch.isOn && weekDays.isEmpty {
            CaronaeAlertController.presentOkAlert(withTitle: "Dados incompletos", message: "Ops! Parece que você esqueceu de marcar os dias da rotina.")
            return
        }
        
        SVProgressHUD.show()
        createRideButton.isEnabled = false
        let ride = generateRideFromView()
        
        RideService.instance.validateRideDate(ride: ride, success: { isValid, status in
            SVProgressHUD.dismiss()
            if isValid {
                self.createRide(ride: ride)
            } else {
                switch status {
                case "duplicate":
                    CaronaeAlertController.presentOkAlert(withTitle: "Você já ofereceu uma carona muito parecida com essa", message: "Você pode verificar as suas caronas na seção 'Minhas' do aplicativo.", handler: {
                        self.createRideButton.isEnabled = true
                    })
                default:
                    let alert = CaronaeAlertController(title: "Parece que você já ofereceu uma carona para este dia", message: "Você pode cancelar e verificar as suas caronas ou continuar e criar a carona mesmo assim.", preferredStyle: .alert)
                    alert?.addAction(SDCAlertAction(title: "Cancelar", style: .cancel, handler: { _ in
                        self.createRideButton.isEnabled = true
                    }))
                    alert?.addAction(SDCAlertAction(title: "Criar", style: .recommended, handler: { _ in
                        self.createRide(ride: ride) }))
                    alert?.present(completion: nil)
                }
            }
            
        }, error: { error in
            SVProgressHUD.dismiss()
            self.createRideButton.isEnabled = true
            
            CaronaeAlertController.presentOkAlert(withTitle: "Não foi possível validar sua carona.", message: String(format: "Houve um erro de comunicação com nosso servidor. Por favor, tente novamente. (%@)", error!.localizedDescription))
        })
    }
    
    
    // MARK: IBActions
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        SVProgressHUD.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func slotsStepperChanged(_ sender: UIStepper) {
        self.view.endEditing(true)
        slotsLabel.text = String(format: "%.f", sender.value)
    }
    
    @IBAction func routineSwitchChanged(_ sender: UISwitch) {
        view.endEditing(true)
        if sender.isOn {
            routinePatternHeight.constant = routinePatternHeightOriginal!
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.routinePatternView.alpha = 1.0
            })
        } else {
            routinePatternHeightOriginal = routinePatternHeight.constant
            routinePatternHeight.constant = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.routinePatternView.alpha = 0.0
            })
        }
    }
    
    @IBAction func routineWeekDayButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            weekDays.append(String(sender.tag))
        } else if let index = weekDays.index(of: String(sender.tag)) {
            weekDays.remove(at: index)
        }
    }
    
    @IBAction func routineDurationButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        routineDuration2MonthsButton.isSelected = false
        routineDuration3MonthsButton.isSelected = false
        routineDuration4MonthsButton.isSelected = false
        sender.isSelected = true
        routineDurationMonths = sender.tag
    }
    
    @IBAction func directionChanged(_ sender: UISegmentedControl) {
        view.endEditing(true)
        guard let lastOfferedRide = userDefaults.dictionary(forKey: CaronaePreferenceLastOfferedRide.key) else {
            selectedHub = ""
            return
        }
        
        if sender.selectedSegmentIndex == 0, let hubGoing = lastOfferedRide[CaronaePreferenceLastOfferedRide.hubGoing] as? String {
            selectedHub = hubGoing
        } else if sender.selectedSegmentIndex == 1, let hubReturning = lastOfferedRide[CaronaePreferenceLastOfferedRide.hubReturning] as? String {
            selectedHub = hubReturning
        } else {
            selectedHub = ""
        }
    }
    
    @IBAction func selectDateTapped(_ sender: Any) {
        self.view.endEditing(true)
        let title = segmentedControl.selectedSegmentIndex == 0 ? PlaceService.Institution.goingLabel : PlaceService.Institution.leavingLabel
        let datePicker = ActionSheetDatePicker(title: title, datePickerMode: .dateAndTime, selectedDate: self.selectedDate, target: self, action: #selector(timeWasSelected(selectedTime:)), origin: sender)
        datePicker?.minimumDate = Date.currentTimePlus(minutes: 5)
        datePicker?.show()
    }
    
    @IBAction func selectCenterTapped(_ sender: Any) {
        let hubType: HubSelectionViewController.HubTypeDirection = (segmentedControl.selectedSegmentIndex == 0) ? .centers : .hubs
        let selectionVC = HubSelectionViewController(selectionType: .oneSelection, hubTypeDirection: hubType)
        selectionVC.delegate = self
        self.navigationController?.show(selectionVC, sender: self)
    }
    
    @IBAction func selectNeighborhoodTapped(_ sender: Any) {
        let selectionVC = NeighborhoodSelectionViewController(selectionType: .oneSelection)
        selectionVC.delegate = self
        self.navigationController?.show(selectionVC, sender: self)
    }
    
    
    // MARK: Selection Methods
    
    @objc func timeWasSelected(selectedTime: Date) {
        selectedDate = selectedTime
    }
    
    func hasSelected(hubs: [String], inCampus campus: String) {
        self.selectedHub = hubs.first!
    }
    
    func hasSelected(neighborhoods: [String], inZone zone: String) {
        self.selectedZone = zone
        self.selectedNeighborhood = neighborhoods.first!
    }

}


// MARK: UITextViewDelegate

extension CreateRideViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == notesPlaceholder {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = notesPlaceholder
            textView.textColor = notesTextColor
        }
        textView.resignFirstResponder()
    }
}
