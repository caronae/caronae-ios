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
    
    func didFailToRegisterForRemoteNotifications(error: NSError) {
        NSLog("Registration for remote notification failed with error: %@", error.localizedDescription)
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            NSLog("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            return;
        }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { error in
            if error != nil {
                NSLog("Unable to connect with FCM. \(error)")
            } else {
                NSLog("Connected to FCM.")
                self.subscribeToUserTopic()
                self.subscribeToGeneralTopic()
            }
        }
    }
    
    func disconnectFromFcm() {
        FIRMessaging.messaging().disconnect()
        NSLog("Disconnected from FCM.")
    }
    
    func subscribeToGeneralTopic() {
        let topic = "/topics/general"
        NSLog("Subscribing to: \(topic)")
        FIRMessaging.messaging().subscribe(toTopic: topic)
    }
    
    func subscribeToUserTopic() {
        if let userTopic = UserService.instance.userTopic {
            NSLog("Subscribing to: \(userTopic)")
            FIRMessaging.messaging().subscribe(toTopic: userTopic)
        }
    }
    
    func registerForNotifications() {
        let application = UIApplication.shared
        
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
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
    
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        NSLog("Remote notification received 1: %@", userInfo)
        
        // Let FCM know about the message for analytics etc.
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        
        _ = handleNotification(userInfo)
    }
    
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any], completionHandler handler: @escaping (UIBackgroundFetchResult) -> Void) {
        let application = UIApplication.shared
        
        if #available(iOS 10.0, *), application.applicationState == .active  {
            NSLog("Remote notification received 2 on iOS 10 or greater")
            handler(UIBackgroundFetchResult.newData)
            return
        }
        
        NSLog("Remote notification received 2: %@", userInfo)
        
        // Let FCM know about the message for analytics etc.
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        
        // If the application received the notification on the background or foreground
        if application.applicationState != .inactive {
            if handleNotification(userInfo) {
                handler(UIBackgroundFetchResult.newData)
            } else {
                handler(UIBackgroundFetchResult.noData)
            }
        }
        // If the app is opening through the notification
        else {
            setActiveScreenAccordingToNotification(userInfo)
            handler(UIBackgroundFetchResult.newData)
        }
    }
    
    func didReceiveLocalNotification(_ notification: UILocalNotification) {
        if UIApplication.shared.applicationState == .inactive {
            NSLog("Opening app from local notification")
            setActiveScreenAccordingToNotification(notification.userInfo)
        }
    }
    
    // [START ios_10_message_handling]
    // Called when a notification is delivered and the app is in foreground
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // Let FCM know about the message for analytics etc.
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        NSLog("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.
        NSLog("%@", userInfo)
        _ = handleNotification(userInfo)
        
        completionHandler([])
    }
    
    // Called when an action was selected by the user for a given notification (app was in background)
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Let FCM know about the message for analytics etc.
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        
        setActiveScreenAccordingToNotification(userInfo)
        completionHandler()
    }
    
    // [START ios_10_data_message_handling]
    // Receive data message on iOS 10 devices while app is in the foreground.
    public func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        NSLog("%@", remoteMessage.appData)
        
        // Let FCM know about the message for analytics etc.
        FIRMessaging.messaging().appDidReceiveMessage(remoteMessage.appData)
        
        _ = handleNotification(remoteMessage.appData)
    }
}
