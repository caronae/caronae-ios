import SwiftMessages

class CaronaeMessagesNotification {
    static let instance = CaronaeMessagesNotification()
    
    private init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    enum MessageKind {
        case success
        case error
    }
    
    func configureMessagesNotification() {
        // Set preferences according to safeArea of device - iPhone X type or not
        if #available(iOS 11.0, *), UIApplication.shared.delegate?.window??.safeAreaInsets != .zero {
            SwiftMessages.defaultConfig.preferredStatusBarStyle = .lightContent
            SwiftMessages.defaultConfig.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        } else {
            SwiftMessages.defaultConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        }
    }
    
    func showMessage(of kind: MessageKind, withText message: String) {
        SwiftMessages.hide()
        SwiftMessages.show {
            let view = MessageView.viewFromNib(layout: .statusLine)
            switch kind {
            case .success:
                view.configureTheme(.success)
                view.backgroundColor = UIColor(red: 0.114, green: 0.655, blue: 0.365, alpha: 1.0)
            case .error:
                view.configureTheme(.error)
            }
            view.configureContent(body: message)
            return view
        }
    }
}
