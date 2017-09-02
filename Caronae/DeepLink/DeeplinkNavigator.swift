import Foundation
import UIKit

enum DeeplinkType {
    case loadRide(withID: Int)
    case openMyRides
    case openActiveRides
    case openRidesHistory
    case openChatForRide(withID: Int)
}

class DeeplinkNavigator {
    
    static let shared = DeeplinkNavigator()
    private init() { }
    
    func proceedToDeeplink(_ type: DeeplinkType) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let tabBarController = appDelegate.window?.rootViewController as? TabBarController else {
            return
        }
        
        switch type {
        case .loadRide(withID: let id):
            tabBarController.selectedViewController = tabBarController.allRidesNavigationController
            let allRidesViewController = tabBarController.allRidesViewController
            allRidesViewController?.loadRide(withID: id)
        case .openMyRides:
            tabBarController.selectedViewController = tabBarController.myRidesNavigationController
        case .openActiveRides:
            tabBarController.selectedViewController = tabBarController.activeRidesNavigationController
        case .openRidesHistory:
            tabBarController.selectedViewController = tabBarController.menuNavigationController
            let menuViewController = tabBarController.menuViewController
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
            tabBarController.selectedViewController = tabBarController.activeRidesNavigationController
            let activeRidesViewController = tabBarController.activeRidesViewController
            activeRidesViewController?.openChatForRide(withID: rideId)
        }
        
    }
    
}
