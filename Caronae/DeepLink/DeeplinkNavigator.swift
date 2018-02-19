import Foundation
import UIKit

enum DeeplinkType {
    case login(withIDUFRJ: String, token: String)
    case loadRide(withID: Int)
    case openMyRides
    case openRidesHistory
    case openChatForRide(withID: Int)
}

class DeeplinkNavigator {
    
    static let shared = DeeplinkNavigator()
    private let authController = AuthenticationController()
    private init() { }
    
    func proceedToDeeplink(_ type: DeeplinkType) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let tabBarController = appDelegate.window?.rootViewController as? TabBarController
        
        switch type {
        case .login(withIDUFRJ: let idUFRJ, token: let token):
            NSLog("Received login URL")
            authController.authenticate(withID: idUFRJ, token: token) { error in
                guard error == nil else {
                    NSLog("There was an error authenticating the user")
                    return
                }
                
                NSLog("User was authenticated. Switching main view controller...")
                let rootViewController = TabBarController()
                UIApplication.shared.keyWindow?.replaceViewController(with: rootViewController)
            }
        case .loadRide(withID: let id):
            tabBarController?.selectedViewController = tabBarController?.allRidesNavigationController
            let allRidesViewController = tabBarController?.allRidesViewController
            allRidesViewController?.loadRide(withID: id)
        case .openMyRides:
            tabBarController?.selectedViewController = tabBarController?.myRidesNavigationController
        case .openRidesHistory:
            tabBarController?.selectedViewController = tabBarController?.menuNavigationController
            let menuViewController = tabBarController?.menuViewController
            menuViewController?.openRidesHistory()
        case .openChatForRide(withID: let rideId):
            guard let topViewController = UIApplication.shared.topViewController() else {
                return
            }

            // Check if chat for rideID is already opened
            if topViewController.isKind(of: ChatViewController.self), let chatVC = topViewController as? ChatViewController {
                if chatVC.ride.id == rideId {
                    return
                }
            }
            
            // Open chat for rideID
            tabBarController?.selectedViewController = tabBarController?.myRidesNavigationController
            let myRidesViewController = tabBarController?.myRidesViewController
            myRidesViewController?.openChatForRide(withID: rideId)
        }
        
    }
    
}
