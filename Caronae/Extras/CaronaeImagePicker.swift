import YPImagePicker

class CaronaeImagePicker {
    static let instance = CaronaeImagePicker()
    private var config = YPImagePickerConfiguration()
    
    private init() {
        config.library.onlySquare = true
        config.usesFrontCamera = true
        config.showsFilters = false
        config.albumName = "Caronaê"
        config.startOnScreen = .library
        config.hidesStatusBar = false
        config.targetImageSize = .cappedTo(size: 960)
    }

    func present(success: @escaping (_ image: UIImage) -> Void) {
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            guard let image = items.singlePhoto?.image else {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            success(image)
            picker.dismiss(animated: true, completion: nil)
        }
        
        if let topViewController = UIApplication.shared.topViewController() {
            topViewController.present(picker, animated: true, completion: nil)
        }
    }
}
