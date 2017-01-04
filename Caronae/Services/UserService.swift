import Foundation
import RealmSwift

class UserService: NSObject {
    static let instance = UserService()
    let api = CaronaeAPIHTTPSessionManager.instance
    
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    var user: User? {
        get {
            // Load the saved user id from UserDefaults
            var userID: Int? = UserDefaults.standard.integer(forKey: "user_id")
            
            // If the user id was not found, check if the user has a legacy 'user' model saved
            // and migrate it to only save the user_id
            if userID == 0, let userJson = UserDefaults.standard.dictionary(forKey: "user") {
                userID = userJson["id"] as? Int
                UserDefaults.standard.set(userID, forKey: "user_id")
                UserDefaults.standard.removeObject(forKey: "user")
            }
            
            guard let realm = try? Realm() else {
                return nil
            }
            
            return realm.object(ofType: User.self, forPrimaryKey: userID)
        }
        
        set {
            if let user = newValue {
                UserDefaults.standard.set(user.id, forKey: "user_id")
                
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(user, update: true)
                    }
                } catch let error {
                    NSLog("Error saving the current user in the Realm: \(error.localizedDescription)")
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "user_id")
                UserDefaults.standard.removeObject(forKey: "user")
            }
        }
    }
    
    var userToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "token")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
    }
    
    var userGCMToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "gcmToken")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "gcmToken")
        }
    }
    
    var userFacebookToken: String? {
        return FBSDKAccessToken.current()?.tokenString
    }
    
    func signIn(withID idUFRJ: String, token: String, success: @escaping (_ user: User) -> Void, error: @escaping (_ error: CaronaeError) -> Void) {
        let params = [ "id_ufrj": idUFRJ, "token": token ]
        api.post("/user/login", parameters: params, success: { task, responseObject in
            guard let responseObject = responseObject as? [String: Any],
            let userJson = responseObject["user"] as? [String: Any] else {
                print("Error parsing user")
                error(.invalidResponse)
                return
            }
            
            // Deserialize and persist response
            let user = User(JSON: userJson)
            self.user = user
            
            // TODO: Use notification instead of calling the app delegate directly
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.registerForNotifications()
            
            success(user!)
            
        }, failure: { task, err in
            NSLog("Failed to sign in: \(err.localizedDescription)")
            
            var authenticationError: CaronaeError = .unknownError
            if let response = task?.response as? HTTPURLResponse {
                switch response.statusCode {
                case 403, 401:
                    authenticationError = .invalidCredentials
                default:
                    authenticationError = .unknownError
                }
            }
            
            error(authenticationError)
        })
    }
    
    func signOut() {
        self.user = nil
        
        guard let realm = try? Realm() else {
            return
        }
        
        // Clear database
        realm.deleteAll()
        
        // Clear notifications
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.deleteAllObjects("Notification")
        appDelegate.updateApplicationBadgeNumber()
        
        // Clear ride requests
        RideRequestsStore.clearAllRequests()
        
        // Logout from Facebook
        FBSDKLoginManager().logOut()
        
        // Go to home screen
        let topViewController = appDelegate.topViewController()
        let authViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "InitialTokenScreen")
        authViewController.modalTransitionStyle = .flipHorizontal
        topViewController?.present(authViewController, animated: true, completion: nil)
    }
    
    func updateUser(_ user: User, success: @escaping () -> Void, error: @escaping (_ error: Error?) -> Void) {
        api.put("/user", parameters: user.toJSON(), success: { task, responseObject in
            
            let currentUser = self.user!
            
            do {
                let realm = try Realm()
                try realm.write {
                    currentUser.phoneNumber = user.phoneNumber
                    currentUser.email = user.email
                    currentUser.carOwner = user.carOwner
                    currentUser.carModel = user.carModel
                    currentUser.carPlate = user.carPlate
                    currentUser.carColor = user.carColor
                    currentUser.location = user.location
                    currentUser.profilePictureURL = user.profilePictureURL
                }
            } catch let err {
                error(err)
            }
            
            NotificationCenter.default.post(name: Notification.Name.CaronaeDidUpdateUser, object: self)
            success()
        }, failure: { task, err in
            error(err)
        })
    }

    
    func ridesCountForUser(withID id: Int, success: @escaping (_ offered: Int, _ taken: Int) -> Void, error: @escaping (_ error: Error?) -> Void) {
        api.get("/ride/getRidesHistoryCount/\(id)", parameters: nil, success: { task, responseObject in
            guard let response = responseObject as? [String: Any],
                let offered = response["offeredCount"] as? Int,
                let taken = response["takenCount"] as? Int else {
                    error(nil)
                    return
            }
            
            // Cache the rides count if the user is persisted
            do {
                let realm = try Realm()
                if let user = realm.object(ofType: User.self, forPrimaryKey: id) {
                    try realm.write {
                        user.numDrives = offered
                        user.numRides = taken
                    }
                }
            } catch {
                NSLog("Error persisting the rides count of the user with id \(id)")
            }
            
            success(offered, taken)
            
        }, failure: { _, err in
            error(err)
        })
    }
    
    // This actually should use the user's ID instead of the Facebook ID
    // but would need to refactor the API...
    func mutualFriendsForUser(withFacebookID facebookID: String, success: @escaping (_ friends: [User], _ totalCount: Int) -> Void, error: @escaping (_ error: Error?) -> Void) {
        guard !facebookID.isEmpty else {
            error(nil)
            return
        }
        
        api.get("/user/\(facebookID)/mutualFriends", parameters: nil, success: { task, responseObject in
            guard let response = responseObject as? [String: Any],
            let friendsJson = response["mutual_friends"] as? [[String: Any]],
                let totalCount = response["total_count"] as? Int else {
                    error(nil)
                    return
            }
            
            let friends = friendsJson.flatMap { User(JSON: $0) }
            success(friends, totalCount)
            
        }, failure: { _, err in
            error(err)
        })
    }

}

enum CaronaeError: Error {
    case invalidCredentials
    case invalidResponse
    case unknownError
}
