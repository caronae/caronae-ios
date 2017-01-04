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
            print("Failed to sign in: \(err.localizedDescription)")
            
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

}

enum CaronaeError: Error {
    case invalidCredentials
    case invalidResponse
    case unknownError
}
