import UIKit
import SVProgressHUD
import AFNetworking
import AudioToolbox
import CRToast

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var beepSound: SystemSoundID = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SVProgressHUD.setBackgroundColor(UIColor(white: 0.0, alpha: 0.75))
        SVProgressHUD.setForegroundColor(.white)
        
        AFNetworkActivityIndicatorManager.shared().isEnabled = true
        AFNetworkReachabilityManager.shared().startMonitoring()
        
        configureRealm()
        configureFirebase()
        configureFacebook(WithLaunchOptions: launchOptions)
        
        // Prepare beepSound for notifications while app is in foreground
        if let soundURL = Bundle.main.url(forResource: "beep", withExtension: "wav") {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &beepSound)
        }
        
        CRToastManager.setDefaultOptions([kCRToastBackgroundColorKey: UIColor(red: 0.114, green: 0.655, blue: 0.365, alpha: 1.0)])
        
        // Load the authentication screen if the user is not signed in
        if UserService.instance.user != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeTabViewController")
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
            registerForNotifications()
            checkIfUserNeedsToFinishProfile()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateUser(notification:)), name: .CaronaeDidUpdateUser, object: nil)
        
        // Update application badge number and listen to notification updates
        updateApplicationBadgeNumber()
        NotificationCenter.default.addObserver(self, selector: #selector(updateApplicationBadgeNumber), name: .CaronaeDidUpdateNotifications, object: nil)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if UserService.instance.user != nil {
            updateUserRidesAndPlaces()
        }
        
        // Handle any deeplink
        deepLinkManager.checkDeepLink()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @objc func didUpdateUser(notification: NSNotification) {
        if UserService.instance.user != nil {
            registerForNotifications()
            updateUserRidesAndPlaces()
            checkIfUserNeedsToFinishProfile()
        } else {
            // Check if the logout was forced by the server
            if let signOutRequired = notification.userInfo?[CaronaeSignOutRequiredKey] as? Bool, signOutRequired {
                CaronaeAlertController.presentOkAlert(withTitle: "Erro de autorização", message: "Ocorreu um erro autenticando seu usuário. Sua chave de acesso pode ter sido redefinida ou suspensa.\n\nPara sua segurança, você será levado à tela de login.", handler: {
                    self.displayAuthenticationScreen()
                })
            } else {
                displayAuthenticationScreen()
            }
            
            disconnectFromFcm()
        }
    }
    
    func checkIfUserNeedsToFinishProfile() {
        if let user = UserService.instance.user, user.isProfileIncomplete {
            DispatchQueue.main.async {
                self.displayFinishProfileScreen()
            }
        }
    }
    
    func displayAuthenticationScreen() {
        let authViewController = TokenViewController.tokenViewController()
        UIApplication.shared.keyWindow?.replaceViewController(with: authViewController)
    }
    
    func displayFinishProfileScreen() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let welcomeViewController = WelcomeViewController.init()
        let welcomeNavigationController = UINavigationController.init(rootViewController: welcomeViewController)
        welcomeNavigationController.modalTransitionStyle = .coverVertical
        welcomeNavigationController.modalPresentationStyle = .overCurrentContext
        rootViewController?.present(welcomeNavigationController, animated: true, completion: nil)
    }
    
    func updateUserRidesAndPlaces() {
        RideService.instance.updateOfferedRides(success: {
            NSLog("Offered rides updated")
        }, error: { error in
            NSLog("Error updating offered rides (\(error.localizedDescription))")
        })
        
        RideService.instance.updateActiveRides(success: {
            NSLog("Active rides updated")
        }, error: { error in
            NSLog("Error updating active rides (\(error.localizedDescription))")
        })
        
        PlaceService.instance.updatePlaces(success: {
            NSLog("Places updated")
        }, error: { error in
            NSLog("Error updating places (\(error.localizedDescription))")
        })
    }
    
    
    // MARK: Facebook SDK
    
    func configureFacebook(WithLaunchOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        FBSDKApplicationDelegate.sharedInstance().application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FBTokenChanged(notification:)), name: .FBSDKAccessTokenDidChange, object: nil)
    }
    
    @objc func FBTokenChanged(notification: NSNotification) {
        guard let token = FBSDKAccessToken.current() else {
            NSLog("User has logged out from Facebook.")
            return
        }
        
        NSLog("Facebook Access Token did change.")
        var fbToken = String()
        if let tokenString = token.tokenString {
            fbToken = tokenString
            NSLog("New Facebook Access Token is %@", tokenString)
        }
        
        var fbID = String()
        if notification.userInfo?[FBSDKAccessTokenDidChangeUserID] != nil {
            if let userID = token.userID {
                NSLog("Facebook has loogged in with Facebook ID %@.", userID)
                fbID = userID
            }
        }
        
        UserService.instance.updateFacebookID(fbID, token: fbToken, success: {
            NSLog("Updated user's Facebook credentials on server.")
        }, error: { error in
            NSLog("Error updating user's Facebook credentials on server: %@", error.localizedDescription)
        })
    }
    
    
    // MARK: Firebase Messaging (FCM)
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("Registration for remote notification failed with error: %@", error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        didReceiveRemoteNotification(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        didReceiveRemoteNotification(userInfo, completionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        didReceiveLocalNotification(notification)
    }
    
    
    // MARK: Deeplinks
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) ||
            deepLinkManager.handleDeepLink(url: url)
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, options: options) ||
            deepLinkManager.handleDeepLink(url: url)
    }
    
    
    // MARK: Universal Links
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL else {
                return false
        }
        return deepLinkManager.handleUniversalLink(url: url)
    }
    
}

