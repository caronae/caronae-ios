import Foundation
import SafariServices
import SVProgressHUD

class AuthenticationController {
    var authSession: AnyObject?
    
    public func openLogin() {
        let authURL = URL(string: CaronaeURLString.login)!
        
        if #available(iOS 11.0, *) {
            let authSession = SFAuthenticationSession(url: authURL, callbackURLScheme: CaronaeURLString.loginCallback, completionHandler: { (url: URL?, authenticationError: Error? ) in
                guard let url = url, authenticationError == nil else {
                    NSLog("SFAuthenticationSession failed")
                    return
                }

                NSLog("SFAuthenticationSession received callback")
                if deepLinkManager.handleDeepLink(url: url) {
                    deepLinkManager.checkDeepLink()
                }
            })

            authSession.start()
            self.authSession = authSession
            return
        }
        
        UIApplication.shared.openURL(authURL)
    }
    
    public func authenticate(withIDUFRJ idUFRJ: String, token: String, callback: @escaping (_ error: CaronaeError?) -> Void) {
        SVProgressHUD.show()
        UserService.instance.signIn(withIDUFRJ: idUFRJ, token: token, success: {
            SVProgressHUD.dismiss()
            callback(nil)
        }, error: { caronaeError in
            SVProgressHUD.dismiss()
            callback(caronaeError)
        })
    }
    
    public func authenticate(withID id: String, token: String, callback: @escaping (_ error: CaronaeError?) -> Void) {
        SVProgressHUD.show()
        UserService.instance.signIn(withID: id, token: token, success: {
            SVProgressHUD.dismiss()
            callback(nil)
        }, error: { caronaeError in
            SVProgressHUD.dismiss()
            callback(caronaeError)
        })
    }
}
