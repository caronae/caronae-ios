import Foundation

class RideService: NSObject {
    static let instance = RideService()
    let api = CaronaeAPIHTTPSessionManager.instance
    
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    func getAllRides(success: @escaping (_ rides: [Ride]) -> Void, error: @escaping (_ error: Error?) -> Void) {
        api.get("/ride/all", parameters: nil, success: { task, responseObject in
            do {
                // Convert JSON dictionary to model
                var rides = try MTLJSONAdapter.models(of: Ride.self, fromJSONArray: responseObject as? [Any]) as! [Ride]
                
                // Skip rides in the past
                rides = rides.filter { $0.date.isInTheFuture() }
                
                // Sort rides by date/time
                rides = rides.sorted { $0.date < $1.date }
                
                success(rides)
            } catch let err {
                print("Error parsing rides: \(err.localizedDescription)")
                error(err)
            }
            
        }, failure: { _, err in
            print("Failed to load all rides: \(err.localizedDescription)")
            error(err)
        })
    }
    
    func removeRideFromMyRides (ride: Ride) {
        // Find and delete ride from persistent store
        guard let userRidesArchive = UserDefaults.standard.object(forKey: "userCreatedRides") as? [Dictionary<String, Any>] else {
            NSLog("Error: userCreatedRides was not found in UserDefaults")
            return
        }
        
        var newRides = userRidesArchive
        for (index, r) in newRides.enumerated() {
            if r["rideId"] as? Int == ride.rideID || r["id"] as? Int == ride.rideID {
                NSLog("Ride with id \(ride.rideID) deleted from user's rides")
                newRides.remove(at: index)
                UserDefaults.standard.set(newRides, forKey: "userCreatedRides")
                return
            }
        }
        NSLog("Error: ride to be deleted was not found in user's rides")
    }
    
    func getOfferedRides(success: @escaping (_ rides: [Dictionary<String, Any>]) -> Void, error: @escaping (_ error: Error?) -> Void) {
        guard let userID = UserController.sharedInstance().user?.userID else {
            NSLog("Error: No userID registered")
            return
        }
        
        api.get("/user/\(userID)/offeredRides", parameters: nil, success: { task, responseObject in
            do {
                let jsonResponse = responseObject as! Dictionary<String, Any?>
                guard let ridesResponse = jsonResponse["rides"] as? [Dictionary<String, Any?>] else {
                    NSLog("Error: rides was not found in responseObject")
                    return
                }
                var ridesArray = [Dictionary<String, Any>]()   
                //DictionaryWithoutNulls
                for rideDictionary in ridesResponse {
                    var new = rideDictionary
                    for (key,value) in new {
                        if value == nil {
                            new[key] = ""
                        }
                    }
                    ridesArray.append(new)
                }
                success(ridesArray)
            }
        }, failure: { _, err in
            NSLog("Error: Failed to get Offered Rides: \(err.localizedDescription)")
            error(err)
        })
    }

//    func getRidesHistory(success: @escaping (_ rides: [Ride]) -> Void, error: @escaping (_ error: Error?) -> Void) {
//        
//    }
//    
//    // etc
}
