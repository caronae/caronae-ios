//
//  AppDelegate+Firebase.swift
//  Caronae
//
//  Created by Rafael Damasceno on 28/10/16.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

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
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
                self.subscribeToUserTopic()
            }
        }
    }
    
    func disconnectFromFcm() {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }
    
    func subscribeToUserTopic() {
        if let userID = UserController.sharedInstance().user?.userID {
            let topic = "/topics/user-\(userID)"
            print("Subscribing to \(topic)")
            FIRMessaging.messaging().subscribe(toTopic: topic)
        }
    }
    
    func unsubscribeFromUserTopic() {
        if let userID = UserController.sharedInstance().user?.userID {
            let topic = "/topics/user-\(userID)"
            print("Unsubscribing from \(topic)")
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
    
    // Receive displayed notifications for iOS 10 devices.
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.
        print("%@", userInfo)
    }
    
    // Receive data message on iOS 10 devices.
    public func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }
}
