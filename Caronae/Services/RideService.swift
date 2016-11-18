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
