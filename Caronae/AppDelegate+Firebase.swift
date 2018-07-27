import Firebase
import UserNotifications

extension AppDelegate {

    func configureFirebase() {
        FirebaseApp.configure()
        NotificationCenter.default.addObserver(self, selector: #selector(messagingDirectChannelStateChanged(_:)), name: .MessagingConnectionStateChanged, object: nil)
    }
    
    func disconnectFromFcm() {
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    @objc func messagingDirectChannelStateChanged(_ notification: Notification) {
        NSLog("FCM Direct Channel Established: \(Messaging.messaging().isDirectChannelEstablished)")
        if Messaging.messaging().isDirectChannelEstablished {
            subscribeToUserAndGeneralTopic()
        }
    }
    
    func subscribeToUserAndGeneralTopic() {
        if let userTopic = UserService.instance.userTopic {
            NSLog("Subscribing to: \(userTopic)")
            Messaging.messaging().subscribe(toTopic: userTopic)
        }
        
        let topic = "general"
        NSLog("Subscribing to: \(topic)")
        Messaging.messaging().subscribe(toTopic: topic)
    }
    
    func registerForNotifications() {
        let application = UIApplication.shared
        
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("Registration for remote notification failed with error: %@", error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NSLog("Remote notification received 1: %@", userInfo)
        
        _ = handleNotification(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if #available(iOS 10.0, *), application.applicationState == .active  {
            NSLog("Remote notification received 2 on iOS 10 or greater")
            completionHandler(UIBackgroundFetchResult.newData)
            return
        }
        
        NSLog("Remote notification received 2: %@", userInfo)
        
        // If the application received the notification on the background or foreground
        if application.applicationState != .inactive {
            if handleNotification(userInfo) {
                completionHandler(UIBackgroundFetchResult.newData)
            } else {
                completionHandler(UIBackgroundFetchResult.noData)
            }
        }
        // If the app is opening through the notification
        else {
            deepLinkManager.handleRemoteNotification(userInfo)
            completionHandler(UIBackgroundFetchResult.newData)
        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if UIApplication.shared.applicationState == .inactive {
            NSLog("Opening app from local notification")
            deepLinkManager.handleRemoteNotification(notification.userInfo)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // [START ios_10_message_handling]
    // Called when a notification is delivered and the app is in foreground
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        NSLog("Notification received on iOS 10 or greater: %@", userInfo)
        _ = handleNotification(userInfo)
        
        completionHandler([])
    }
    
    // Called when an action was selected by the user for a given notification (app was in background)
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NSLog("Opening app from local notification on iOS 10 or greater")
        deepLinkManager.handleRemoteNotification(userInfo)
        completionHandler()
    }
    
    // [START ios_10_data_message_handling]
    // Receive data message on iOS 10 devices while app is in the foreground.
    public func application(received remoteMessage: MessagingRemoteMessage) {
        NSLog("Data message received on iOS 10 or greater: %@", remoteMessage.appData)
        _ = handleNotification(remoteMessage.appData)
    }
}

extension AppDelegate: MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        NSLog("Firebase registration token: \(fcmToken)")
        subscribeToUserAndGeneralTopic()
    }
    
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        NSLog("Received data message from FCM (bypassing APNs): %@", remoteMessage.appData)
        _ = handleNotification(remoteMessage.appData)
    }
}
