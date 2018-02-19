//
//  AuthenticationController.swift
//  Caronae
//
//  Created by Mario Cecchi on 18/02/2018.
//  Copyright © 2018 Mario Cecchi. All rights reserved.
//

import Foundation
import SafariServices

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
        }
        
        // TODO: other iOS versions
    }
    
    public func authenticate(withID idUFRJ: String, token: String, callback: @escaping (_ error: CaronaeError?) -> Void) {
        // TODO: loading indicator on screen
        UserService.instance.signIn(withID: idUFRJ, token: token, success: { _ in
            callback(nil)
        }, error: { caronaeError in
            callback(caronaeError)
        })
    }

}
