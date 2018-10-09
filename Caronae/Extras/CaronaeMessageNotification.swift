import SwiftMessages

class CaronaeMessagesNotification {
    static let instance = CaronaeMessagesNotification()
    
    private init() {
        // Set preferences according to safeArea of device - iPhone X type or not
        if #available(iOS 11.0, *), UIApplication.shared.delegate?.window??.safeAreaInsets != .zero {
            SwiftMessages.defaultConfig.preferredStatusBarStyle = .lightContent
            SwiftMessages.defaultConfig.presentationContext = .window(windowLevel: .normal)
        } else {
            SwiftMessages.defaultConfig.presentationContext = .window(windowLevel: .statusBar)
        }
    }
    
    func showSuccess(withText message: String) {
        SwiftMessages.hide()
        SwiftMessages.show {
            let view = MessageView.viewFromNib(layout: .statusLine)
            view.configureTheme(.success)
            view.backgroundColor = UIColor(red: 0.114, green: 0.655, blue: 0.365, alpha: 1.0)
            view.configureContent(body: message)
            return view
        }
    }
    
    func showError(withText message: String) {
        SwiftMessages.hide()
        SwiftMessages.show {
            let view = MessageView.viewFromNib(layout: .statusLine)
            view.configureTheme(.error)
            view.configureContent(body: message)
            return view
        }
    }
}
