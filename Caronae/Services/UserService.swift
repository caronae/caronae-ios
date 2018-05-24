import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import Foundation
import RealmSwift
import SimpleKeychain

class UserService: NSObject {
    static let instance = UserService()
    private let api = CaronaeAPIHTTPSessionManager.instance
    
    private override init() {}
    
    private(set) lazy var user: User? = {
        do {
            let realm = try Realm()
            return realm.object(ofType: User.self, forPrimaryKey: userID)
        } catch {
            NSLog("Error reading current user (%@)", error.localizedDescription)
            return nil
        }
    }()
    
    private(set) var userID: Int? {
        get { return UserDefaults.standard.integer(forKey: "user_id") }
        set {
            guard let id = newValue else {
                UserDefaults.standard.removeObject(forKey: "user_id")
                return
            }
            UserDefaults.standard.set(id, forKey: "user_id")
        }
    }

    var userToken: String? {
        get { return UserDefaults.standard.string(forKey: "token") }
        set {
            guard let token = newValue else {
                UserDefaults.standard.removeObject(forKey: "token")
                return
            }
            UserDefaults.standard.set(token, forKey: "token")
        }
    }

    var jwtToken: String? {
        get { return A0SimpleKeychain().string(forKey: "jwt_token") }
        set {
            guard let token = newValue else {
                A0SimpleKeychain().deleteEntry(forKey: "jwt_token")
                return
            }
            A0SimpleKeychain().setString(token, forKey: "jwt_token")
        }
    }
    
    var userFacebookToken: String? {
        return FBSDKAccessToken.current()?.tokenString
    }
    
    var userTopic: String? {
        guard let user = self.user else {
            return nil
        }
        return "/topics/user-\(user.id)"
    }
    
    func getUser(withID id: String, success: @escaping (_ user: User) -> Void, error: @escaping (_ error: Error) -> Void) {
        api.get("/api/v1/users/\(id)", parameters: nil, progress: nil, success: { task, responseObject in
            guard let responseObject = responseObject as? [String: Any],
                let userJson = responseObject["user"] as? [String: Any],
                let user = User(JSON: userJson) else {
                    NSLog("Error parsing user response")
                    error(CaronaeError.invalidResponse)
                    return
            }
            
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(user, update: true)
                }
            } catch let realmError {
                NSLog("Error saving the current user in the Realm: \(realmError.localizedDescription)")
            }

            success(user)
        }, failure: { task, err in
            NSLog("Error loading user with id \(id): \(err.localizedDescription)")
            error(err)
        })
    }
    
    func signIn(withID id: String, token: String, success: @escaping () -> Void, error: @escaping (_ error: CaronaeError) -> Void) {
        self.jwtToken = token
        getUser(withID: id, success: { user in
            self.user = user
            self.userID = user.id
            self.notifyObservers()
            
            PlaceService.instance.updatePlaces(success: {
                success()
            }, error: { err in
                NSLog("Failed to update places: \(err.localizedDescription)")
                error(.invalidResponse)
            })
            
        }) { err in
            NSLog("Failed to sign in: \(err.localizedDescription)")
            error(.invalidResponse)
        }
    }
    
    func signIn(withIDUFRJ idUFRJ: String, token: String, success: @escaping () -> Void, error: @escaping (_ error: CaronaeError) -> Void) {
        let params = [ "id_ufrj": idUFRJ, "token": token ]
        api.post("/api/v1/users/login", parameters: params, progress: nil, success: { task, responseObject in
            guard let responseObject = responseObject as? [String: Any],
            let userJson = responseObject["user"] as? [String: Any],
            let user = User(JSON: userJson) else {
                NSLog("Error parsing user response")
                error(.invalidResponse)
                return
            }
            
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(user, update: true)
                }
            } catch let realmError {
                NSLog("Error saving the current user in the Realm: \(realmError.localizedDescription)")
            }

            // Update the current user
            self.user = user
            self.userID = user.id
            self.userToken = token
            
            self.migrateToJWT(success: {
                NSLog("Successfully migrate to jwt token")
                self.notifyObservers()
                
                PlaceService.instance.updatePlaces(success: {
                    success()
                }, error: { err in
                    NSLog("Failed to update places: \(err.localizedDescription)")
                    error(.invalidResponse)
                })
                
            }, error: { err in
                error(.invalidResponse)
            })
            
        }, failure: { task, err in
            NSLog("Failed to sign in: \(err.localizedDescription)")
            
            var authenticationError: CaronaeError = .invalidResponse
            if let response = task?.response as? HTTPURLResponse {
                switch response.statusCode {
                case 403, 401:
                    authenticationError = .invalidCredentials
                default:
                    authenticationError = .invalidResponse
                }
            }
            
            error(authenticationError)
        })
    }
    
    func migrateToJWT(success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        guard let userID = self.userID else {
            NSLog("Error: No userID registered")
            return error(CaronaeError.invalidUser)
        }
        api.get("/api/v1/users/\(userID)/token", parameters: nil, progress: nil, success: { _, _ in
            success()
        }, failure: { task, err in
            NSLog("Error getting user jwt token: \(err.localizedDescription)")
            error(err)
        })
    }
    
    func signOut(force: Bool = false) {
        // Unsubscribe from FCM user topic
        if let userTopic = self.userTopic {
            NSLog("Unsubscribing from: \(userTopic)")
            Messaging.messaging().unsubscribe(fromTopic: userTopic)
        }
        
        // Clear database
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            NSLog("Error deleting Realm. %@", error.localizedDescription)
        }
        
        // Clear notifications
        NotificationService.instance.clearNotifications()
        
        // Logout from Facebook
        FBSDKLoginManager().logOut()
        
        // Clear current user
        self.user = nil
        self.userID = nil
        self.userToken = nil
        self.jwtToken = nil
        
        notifyObservers(force: force)
    }
    
    func updateUser(_ user: User, success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        api.put("/api/v1/users/\(user.id)", parameters: user.toJSON(), success: { task, responseObject in
            
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
            } catch let realmError {
                error(realmError)
            }
            
            NotificationCenter.default.post(name: .CaronaeDidUpdateUser, object: self)
            success()
        }, failure: { _, err in
            error(err)
        })
    }
    
    func updateFacebookID(_ id: Any, success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        guard let user = UserService.instance.user else {
            NSLog("Error: No userID registered")
            return
        }
        
        let params = [ "facebook_id": id ]
        api.put("/api/v1/users/\(user.id)", parameters: params, success: { task, responseObject in
            success()
        }, failure: { _, err in
            error(err)
        })
    }
    
    func getPhotoFromFacebook(success: @escaping (_ url: String) -> Void, error: @escaping (_ error: Error) -> Void) {
        let request = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: ["fields": "url"])!
        request.start(completionHandler: { connection, result, err in
            guard err == nil,
            let response = result as? [String: Any],
            let data = response["data"] as? [String: Any],
                let url = data["url"] as? String else {
                    error(CaronaeError.invalidResponse)
                    return
            }
            
            success(url)
        })
    }
    
    func uploadPhotoFromDevice(_ image: UIImage, success: @escaping (_ url: String) -> Void, error: @escaping (_ error: Error) -> Void) {
        guard let userID = self.userID else {
            NSLog("Error: No userID registered")
            return error(CaronaeError.invalidUser)
        }
        
        let imageData = UIImageJPEGRepresentation(image, 1.0)!
        api.post("/api/v1/users/\(userID)/profile_picture", parameters: nil, constructingBodyWith: { fromData in
            fromData.appendPart(withFileData: imageData, name: "profile_picture", fileName: "profile_picture.jpeg", mimeType: "image/jpeg")
        }, progress: nil, success: { _, responseObject in
            guard let responseObject = responseObject as? [String: Any],
                let pictureURL = responseObject["profile_pic_url"] as? String else {
                    NSLog("Error receiving profile picture url after upload")
                    error(CaronaeError.invalidResponse)
                    return
            }
            
            success(pictureURL)
        }, failure: { _, err in
            error(err)
        })
    }
    
    func ridesCountForUser(withID id: Int, success: @escaping (_ offered: Int, _ taken: Int) -> Void, error: @escaping (_ error: Error) -> Void) {
        api.get("/api/v1/users/\(id)/rides/history", parameters: nil, progress: nil, success: { task, responseObject in
            guard let response = responseObject as? [String: Any],
                let offered = response["offered_rides_count"] as? Int,
                let taken = response["taken_rides_count"] as? Int else {
                    error(CaronaeError.invalidResponse)
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
    func mutualFriendsForUser(withFacebookID facebookID: String?, success: @escaping (_ friends: [User], _ totalCount: Int) -> Void, error: @escaping (_ error: Error) -> Void) {
        guard let facebookID = facebookID, !facebookID.isEmpty, userFacebookToken != nil else {
            error(CaronaeError.notLoggedInWithFacebook)
            return
        }
        
        api.get("/user/\(facebookID)/mutualFriends", parameters: nil, progress: nil, success: { task, responseObject in
            guard let response = responseObject as? [String: Any],
            let friendsJson = response["mutual_friends"] as? [[String: Any]],
                let totalCount = response["total_count"] as? Int else {
                    error(CaronaeError.invalidResponse)
                    return
            }
            
            let friends = friendsJson.compactMap { User(JSON: $0) }
            success(friends, totalCount)
        }, failure: { _, err in
            error(err)
        })
    }
    
    private func notifyObservers(force: Bool = false) {
        NotificationCenter.default.post(name: .CaronaeDidUpdateUser, object: self, userInfo: [CaronaeSignOutRequiredKey: force])
    }
}
