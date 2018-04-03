import Foundation
import UIKit

enum DeeplinkType {
    case login(withID: String, token: String)
    case loadRide(withID: Int)
    case loadAcceptedRide(withID: Int)
    case openMyRides
    case openRidesHistory
    case openRide(withID: Int, openChat: Bool)
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
        case .login(withID: let id, token: let token):
            NSLog("Received login URL")
            authController.authenticate(withID: id, token: token) { error in
                guard error == nil else {
                    NSLog("There was an error authenticating the user. %@", error!.localizedDescription)
                    CaronaeAlertController.presentOkAlert(withTitle: "Não foi possível autenticar", message: error!.localizedDescription)
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
        case .loadAcceptedRide(withID: let id):
            tabBarController?.selectedViewController = tabBarController?.myRidesNavigationController
            let myRidesViewController = tabBarController?.myRidesViewController
            myRidesViewController?.loadAcceptedRide(withID: id)
        case .openMyRides:
            tabBarController?.selectedViewController = tabBarController?.myRidesNavigationController
        case .openRidesHistory:
            tabBarController?.selectedViewController = tabBarController?.menuNavigationController
            let menuViewController = tabBarController?.menuViewController
            menuViewController?.openRidesHistory()
        case .openRide(withID: let rideId, openChat: let openChat):
            guard let topViewController = UIApplication.shared.topViewController() else {
                return
            }

            // Check if chat for rideID is already opened
            if openChat, topViewController.isKind(of: ChatViewController.self), let chatVC = topViewController as? ChatViewController, chatVC.ride.id == rideId {
                return
            }
            
            // Check if ride with rideID is already opened
            if topViewController.isKind(of: RideViewController.self), let rideVC = topViewController as? RideViewController, rideVC.ride.id == rideId {
                if openChat {
                    rideVC.openChatWindow()
                }
                return
            }
            
            // Open ride
            tabBarController?.selectedViewController = tabBarController?.myRidesNavigationController
            let myRidesViewController = tabBarController?.myRidesViewController
            myRidesViewController?.openRide(withID: rideId, openChat: openChat)
        }
    }
    
}
