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
    
    func validateRideDate(ride: [String : Any], success: @escaping (_ valid: NSNumber, _ status: String) -> Void, error: @escaping (_ error: Error?) -> Void) {
        let params = ["date": ride["mydate"]!, "time" : ride["mytime"]!, "going" : ride["going"]!]
        
        api.get("/ride/validateDuplicate?", parameters: params, success: { task, responseObject in
            let response = responseObject as! [String : Any]
            success (response["valid"]! as! NSNumber, response["status"]! as! String)
            
        }, failure: { _, err in
            NSLog("Failed to validate ride date: \(err.localizedDescription)")
            error(err)
        })
    }
    
//    func getMyRides(success: @escaping (_ rides: [Ride]) -> Void, error: @escaping (_ error: Error?) -> Void) {
//        
//    }
//    
//    func getRidesHistory(success: @escaping (_ rides: [Ride]) -> Void, error: @escaping (_ error: Error?) -> Void) {
//        
//    }
//    
//    // etc
}
