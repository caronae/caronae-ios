import Firebase
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate, FIRMessagingDelegate {

    func configureFirebase() {
        FIRApp.configure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(tokenRefreshNotification), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)

    }
    
    func didRegisterForRemoteNotifications(deviceToken: NSData) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type: FIRInstanceIDAPNSTokenType.sandbox)
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            NSLog("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                
                NSLog("Unable to connect with FCM. \(error)")
            } else {
                NSLog("Connected to FCM.")
                self.subscribeToUserTopic()
            }
        }
    }
    
    func disconnectFromFcm() {
        FIRMessaging.messaging().disconnect()
        NSLog("Disconnected from FCM.")
    }
    
    func subscribeToUserTopic() {
        if let userID = UserController.sharedInstance().user?.userID {
            let topic = "/topics/user-\(userID)"
            NSLog("Subscribing to: \(topic)")
            FIRMessaging.messaging().subscribe(toTopic: topic)
        }
    }
    
    func unsubscribeFromUserTopic() {
        if let userID = UserController.sharedInstance().user?.userID {
            let topic = "/topics/user-\(userID)"
            NSLog("Unsubscribing from: \(topic)")
            FIRMessaging.messaging().unsubscribe(fromTopic: topic)
        }
    }
    
    func registerForNotifications() {
        let application = UIApplication.shared
        
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    // [START ios_10_message_handling]
    // Called when a notification is delivered and the app is in foreground
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        NSLog("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.
        NSLog("%@", userInfo)
        handleNotification(userInfo)
    }
    
    // Called when an action was selected by the user for a given notification (app was in background)
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        NSLog("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.
        print("%@", userInfo)
        handleNotification(userInfo)
    }
    
    // [START ios_10_data_message_handling]
    // Receive data message on iOS 10 devices while app is in the foreground.
    public func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        NSLog("%@", remoteMessage.appData)
        handleNotification(remoteMessage.appData)
    }
}
