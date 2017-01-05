import Foundation
import RealmSwift

class RideService: NSObject {
    static let instance = RideService()
    let api = CaronaeAPIHTTPSessionManager.instance
    
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    func getAllRides(success: @escaping (_ rides: [Ride]) -> Void, error: @escaping (_ error: Error?) -> Void) {
        api.get("/ride/all", parameters: nil, success: { task, responseObject in
            guard let ridesJson = responseObject as? [[String: Any]] else {
                print("Error parsing rides")
                error(nil)
                return
            }
            
            // Deserialize response
            var rides = ridesJson.flatMap { Ride(JSON: $0) }
            
            // Skip rides in the past
            rides = rides.filter { $0.date.isInTheFuture() }
            
            // Sort rides by date/time
            rides = rides.sorted { $0.date < $1.date }
            
            success(rides)

        }, failure: { _, err in
            print("Failed to load all rides: \(err.localizedDescription)")
            error(err)
        })
    }
    
    func getOfferedRides(success: @escaping (_ rides: Results<Ride>) -> Void, error: @escaping (_ error: Error?) -> Void) {
        let user = UserService.instance.user!
        
        do {
            let realm = try Realm()
            let rides = realm.objects(Ride.self).filter("driver == %@", user)
            success(rides)
        } catch let err {
            error(err)
        }
    }
    
    func updateOfferedRides(success: @escaping (_ rides: [Ride]) -> Void, error: @escaping (_ error: Error?) -> Void) {
        guard let user = UserService.instance.user else {
            NSLog("Error: No userID registered")
            return
        }
        
        api.get("/user/\(user.id)/offeredRides", parameters: nil, success: { task, responseObject in
            guard let jsonResponse = responseObject as? [String: Any],
                let ridesJson = jsonResponse["rides"] as? [[String: Any]] else {
                NSLog("Error: rides was not found in responseObject")
                error(nil)
                return
            }
            
            // Deserialize response
            let rides = ridesJson.flatMap {
                let ride = Ride(JSON: $0)
                ride?.driver = user
                return ride
            } as [Ride]
            
            // TODO: Subscribe to ride topics
            
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(rides, update: true)
                }
            } catch _ {
                error(nil)
            }
            
            success(rides)
        }, failure: { _, err in
            NSLog("Error: Failed to get offered rides: \(err.localizedDescription)")
            error(err)
        })
    }

    func getActiveRides(success: @escaping (_ rides: [Ride]) -> Void, error: @escaping (_ error: Error?) -> Void) {
        api.get("/ride/getMyActiveRides", parameters: nil, success: { task, responseObject in
            guard let ridesJson = responseObject as? [[String: Any]] else {
                NSLog("Error: Invalid response from the API")
                error(nil)
                return
            }
            
            let rides = ridesJson.flatMap { Ride(JSON: $0) }.sorted { $0.date < $1.date }
            success(rides)
        }, failure: { _, err in
            NSLog("Error: Failed to get active rides: \(err.localizedDescription)")
            error(err)
        })
    }
    
    func getRidesHistory(success: @escaping (_ rides: [Ride]) -> Void, error: @escaping (_ error: Error?) -> Void) {
        api.get("/ride/getRidesHistory", parameters: nil, success: { task, responseObject in
            guard let ridesJson = responseObject as? [[String: Any]] else {
                NSLog("Error: Invalid response from the API")
                error(nil)
                return
            }
            
            // Deserialize rides and order starting from the newest ride
            let rides = ridesJson.flatMap { Ride(JSON: $0) }.sorted { $0.date > $1.date }
            success(rides)
        }, failure: { _, err in
            error(err)
        })
    }

    func searchRides(withCenter center: String, neighborhoods: [String], date: Date, going: Bool, success: @escaping (_ rides: [Ride]) -> Void, error: @escaping (_ error: Error?) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: date)
        
        let params = [
            "center": center,
            "location": neighborhoods.joined(separator: ", "),
            "date": dateString,
            "time": timeString,
            "go": going
        ] as [String : Any]
        
        api.post("/ride/listFiltered", parameters: params, success: { task, responseObject in
            guard let ridesJson = responseObject as? [[String: Any]] else {
                NSLog("Error: Invalid response from the API")
                error(nil)
                return
            }
            
            let rides = ridesJson.flatMap { Ride(JSON: $0) }.sorted { $0.date < $1.date }
            success(rides)
        }, failure: { _, err in
            NSLog("Error: Failed to search rides: \(err.localizedDescription)")
            error(err)
        })
    }
    
    func getRequestersForRide(withID id: Int, success: @escaping (_ rides: [User]) -> Void, error: @escaping (_ error: Error?) -> Void) {
        api.get("/ride/getRequesters/\(id)", parameters: nil, success: { task, responseObject in
            guard let usersJson = responseObject as? [[String: Any]] else {
                error(nil)
                return
            }
            
            let users = usersJson.flatMap { User(JSON: $0) }
            success(users)
        }, failure: { _, err in
            error(err)
        })
    }

    func createRide(_ ride: Ride, success: @escaping (_ rides: [Ride]) -> Void, error: @escaping (_ error: Error?) -> Void) {
        api.post("/ride", parameters: ride.toJSON(), success: { task, responseObject in
            guard let ridesJson = responseObject as? [[String: Any]] else {
                error(nil)
                return
            }
            
            let user = UserService.instance.user!
            let rides = ridesJson.flatMap {
                let ride = Ride(JSON: $0)
                ride?.driver = user
                return ride
                } as [Ride]
            
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(rides, update: true)
                }
            } catch _ {
                error(nil)
            }
            
            success(rides)
        }, failure: { task, err in
            error(err)
        })
    }
    
    func finishRide(withID id: Int, success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        api.post("/ride/finishRide", parameters: ["rideId": id], success: { task, responseObject in
            do {
                let realm = try Realm()
                if let ride = realm.object(ofType: Ride.self, forPrimaryKey: id) {
                    try realm.write {
                        realm.delete(ride)
                    }
                    
                    // TODO: Unsubcribe from ride topic and clear notifications
                } else {
                    NSLog("Ride with id %d not found locally in user's rides", id)
                }
            } catch let err {
                error(err)
            }
            
            success()
        }, failure: { task, err in
            error(err)
        })
    }

    func leaveRide(withID id: Int, success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        api.post("/ride/leaveRide", parameters: ["rideId": id], success: { task, responseObject in
            do {
                let realm = try Realm()
                if let ride = realm.object(ofType: Ride.self, forPrimaryKey: id) {
                    try realm.write {
                        realm.delete(ride)
                    }
                    
                    // TODO: Unsubcribe from ride topic and clear notifications
                } else {
                    NSLog("Rides with routine id %d not found locally in user's rides", id)
                }
            } catch let err {
                error(err)
            }
            
            success()
        }, failure: { task, err in
            error(err)
        })
    }
    
    func deleteRoutine(withID id: Int, success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        api.delete("/ride/allFromRoutine/\(id)", parameters: nil, success: { task, responseObject in
            do {
                let realm = try Realm()
                let rides = realm.objects(Ride.self).filter("routineID == %@", id)
                if !rides.isEmpty {
                    try realm.write {
                        realm.delete(rides)
                    }
                    
                    // TODO: Unsubcribe from ride topic and clear notifications
                } else {
                    NSLog("Ride with id %d not found locally in user's rides", id)
                }
            } catch let err {
                error(err)
            }
            
            success()
        }, failure: { task, err in
            error(err)
        })
    }
    
    func requestJoinOnRide(withID id: Int, success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        api.post("/ride/requestJoin", parameters: ["rideId": id], success: { task, responseObject in
            // TODO: Persist join requests
            success()
        }, failure: { task, err in
            error(err)
        })
    }
    
    func answerRequestOnRide(withID rideID: Int, fromUser user: User, accepted: Bool, success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        let params = [
            "rideId": rideID,
            "userId": user.id,
            "accepted": accepted
        ] as [String: Any]
        
        api.post("/ride/answerJoinRequest", parameters: params, success: { task, responseObject in
            do {
                let realm = try Realm()
                if let ride = realm.object(ofType: Ride.self, forPrimaryKey: rideID) {
                    try realm.write {
                        ride.riders.append(user)
                    }
                } else {
                    NSLog("Ride with id %d not found locally in user's rides", rideID)
                }
            } catch let err {
                error(err)
            }

            success()
        }, failure: { task, err in
            error(err)
        })
    }
    
}
