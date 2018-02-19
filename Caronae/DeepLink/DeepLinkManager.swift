import Foundation
import UIKit

let deepLinkManager = DeepLinkManager()
class DeepLinkManager {
    fileprivate init() {}
    
    private var deeplinkType: DeeplinkType?
    
    func handleRemoteNotification(_ notification: [AnyHashable: Any]?) {
        deeplinkType = NotificationParser.shared.handleNotification(notification)
    }
    
    func handleUniversalLink(url: URL) -> Bool {
        deeplinkType = UniversalLinkParser.shared.parseLink(url)
        return deeplinkType != nil
    }
    
    func handleDeepLink(url: URL) -> Bool {
        deeplinkType = UniversalLinkParser.shared.parseDeeplink(url)
        return deeplinkType != nil
    }
    
    // Check existing deeplink and perform action
    func checkDeepLink() {
        guard let deeplinkType = deeplinkType else {
            return
        }
        
        DeeplinkNavigator.shared.proceedToDeeplink(deeplinkType)
        
        // Reset deeplink after handling
        self.deeplinkType = nil
    }
}
