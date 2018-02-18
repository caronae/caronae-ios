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

    @available(iOS 11.0, *)
    func authenticate(success: @escaping (_ idUFRJ: String, _ token: String) -> Void) {
        let authURL = URL(string: CaronaeURLString.login)!
        let authSession = SFAuthenticationSession(url: authURL, callbackURLScheme: CaronaeURLString.loginCallback, completionHandler: { (url: URL?, error: Error? ) in
            guard let url = url, error == nil else {
                print(error!)
                NSLog("AuthenticationSession failed")
                return
            }
            
            guard let (idUFRJ, token) = self.getAuthenticationData(url) else {
                NSLog("User data not found in response")
                return
            }
            
            NSLog("User was authenticated")
            success(idUFRJ, token)
        })

        authSession.start()
        self.authSession = authSession
    }
    
    private func getAuthenticationData(_ url: URL) -> (String, String)? {
        let urlString = url.absoluteString
        guard let idUFRJ = self.getQueryParameter(url: urlString, param: "id_ufrj"),
            let token = self.getQueryParameter(url: urlString, param: "token") else {
                return nil
        }
        
        return (idUFRJ, token)
    }
    
    private func getQueryParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }

}
