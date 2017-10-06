import Foundation
import RealmSwift

class RideService: NSObject {
    static let instance = RideService()
    let api = CaronaeAPIHTTPSessionManager.instance
    
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    func getRides(page: Int, filterParameters: FilterParameters? = nil, success: @escaping (_ rides: [Ride], _ lastPage: Int) -> Void, error: @escaping (_ error: Error) -> Void) {
        
        api.get("/rides?page=\(page)", parameters: filterParameters?.dictionary(), success: { task, responseObject in
            guard let response = responseObject as? [String: Any],
                let ridesJson = response["data"] as? [[String: Any]],
                let lastPage = response["last_page"] as? Int else {
                    error(CaronaeError.invalidResponse)
                    return
            }
            
            var rides = ridesJson.flatMap { Ride(JSON: $0) }
            rides = rides.sorted { $0.date < $1.date }
            
            success(rides, lastPage)
        }, failure: { _, err in
            NSLog("Failed to load rides: \(err.localizedDescription)")
            error(err)
        })
    }
    
    func getOfferedRides(success: @escaping (_ rides: Results<Ride>) -> Void, error: @escaping (_ error: Error) -> Void) {
        guard let user = UserService.instance.user else {
            NSLog("Error: No userID registered")
            return
        }
        
        do {
            let realm = try Realm()
            let currentDate = Date()
            let rides = realm.objects(Ride.self).filter("driver == %@ AND date >= %@", user, currentDate).sorted(byKeyPath: "date")
            
            success(rides)
        } catch let realmError {
            error(realmError)
        }
    }
    
    func updateOfferedRides(success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        guard let user = UserService.instance.user else {
            NSLog("Error: No userID registered")
            return
        }
        
        api.get("/user/\(user.id)/offeredRides", parameters: nil, success: { task, responseObject in
            guard let jsonResponse = responseObject as? [String: Any],
                let ridesJson = jsonResponse["rides"] as? [[String: Any]] else {
                error(CaronaeError.invalidResponse)
                return
            }
            
            // Deserialize response
            let rides = ridesJson.flatMap { rideJson in
                let ride = Ride(JSON: rideJson)
                ride?.driver = user
                if let riders = ride?.riders, !riders.isEmpty {
                    ride?.isActive = true
                }
                return ride
            } as [Ride]
            
            do {
                let realm = try Realm()
                let currentDate = Date()
                let ridesInThePast = realm.objects(Ride.self).filter("date < %@ AND isActive == false", currentDate)
                
                // Clear notifications for inactive rides in the past
                ridesInThePast.forEach { ride in
                    NotificationService.instance.clearNotifications(forRideID: ride.id)
                }
                
                // Delete inactive rides in the past
                try realm.write {
                    ridesInThePast.forEach { ride in
                        realm.delete(ride)
                    }
                }
                
                // Update offered rides
                try realm.write {
                    realm.add(rides, update: true)
                }
            } catch let realmError {
                error(realmError)
            }
            
            success()
        }, failure: { _, err in
            NSLog("Error: Failed to get offered rides: \(err.localizedDescription)")
            error(err)
        })
    }

    func getActiveRides(success: @escaping (_ rides: Results<Ride>) -> Void, error: @escaping (_ error: Error) -> Void) {
        do {
            let realm = try Realm()
            let rides = realm.objects(Ride.self).filter("isActive == true").sorted(byKeyPath: "date")
            
            success(rides)
        } catch let realmError {
            error(realmError)
        }
    }
    
    func updateActiveRides(success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        api.get("/ride/getMyActiveRides", parameters: nil, success: { task, responseObject in
            guard let ridesJson = responseObject as? [[String: Any]] else {
                error(CaronaeError.invalidResponse)
                return
            }
            
            // Deserialize response
            let rides = ridesJson.flatMap { rideJson in
                let ride = Ride(JSON: rideJson)
                ride?.isActive = true
                return ride
            } as [Ride]
            
            do {
                let realm = try Realm()
                // Clear rides previously marked as active
                let previouslyActives = Array(realm.objects(Ride.self).filter("isActive == true"))
                try realm.write {
                    previouslyActives.forEach { $0.isActive = false }
                }
                
                // Clear notifications for finished/canceled rides
                let currentActiveIDs = rides.flatMap { $0.id }
                var previouslyActiveIDs = Set(previouslyActives.flatMap { $0.id })
                previouslyActiveIDs.subtract(currentActiveIDs)
                previouslyActiveIDs.forEach { id in
                    NotificationService.instance.clearNotifications(forRideID: id, of: [.chat, .rideJoinRequestAccepted])
                }
                
                // Update active rides
                try realm.write {
                    realm.add(rides, update: true)
                }
            } catch let realmError {
                error(realmError)
            }
            
            success()
        }, failure: { _, err in
            error(err)
        })
    }
    
    func getRide(withID id: Int, success: @escaping (_ ride: Ride, _ availableSlots: Int) -> Void, error: @escaping (_ error: CaronaeError) -> Void) {
        api.get("/ride/\(id)", parameters: nil, success: { task, responseObject in
            guard let rideJson = responseObject as? [String: Any],
                let ride = Ride(JSON: rideJson),
                let availableSlots = rideJson["availableSlots"] as? Int else {
                    error(CaronaeError.invalidRide)
                    return
            }
            
            success(ride, availableSlots)
        }, failure: { task, err in
            NSLog("Failed to load ride with id \(id): \(err.localizedDescription)")
            
            var caronaeError: CaronaeError = .invalidResponse
            if let response = task?.response as? HTTPURLResponse {
                switch response.statusCode {
                case 404:
                    caronaeError = .invalidRide
                default:
                    caronaeError = .invalidResponse
                }
            }
            
            error(caronaeError)
        })
    }
    
    func getRidesHistory(success: @escaping (_ rides: [Ride]) -> Void, error: @escaping (_ error: Error) -> Void) {
        api.get("/ride/getRidesHistory", parameters: nil, success: { task, responseObject in
            guard let ridesJson = responseObject as? [[String: Any]] else {
                error(CaronaeError.invalidResponse)
                return
            }
            
            // Deserialize rides and order starting from the newest ride
            let rides = ridesJson.flatMap { Ride(JSON: $0) }.sorted { $0.date > $1.date }
            success(rides)
        }, failure: { _, err in
            error(err)
        })
    }
    
    func getRequestersForRide(withID id: Int, success: @escaping (_ rides: [User]) -> Void, error: @escaping (_ error: Error) -> Void) {
        api.get("/ride/getRequesters/\(id)", parameters: nil, success: { task, responseObject in
            guard let usersJson = responseObject as? [[String: Any]] else {
                error(CaronaeError.invalidResponse)
                return
            }
            
            let users = usersJson.flatMap { User(JSON: $0) }
            success(users)
        }, failure: { _, err in
            error(err)
        })
    }

    func createRide(_ ride: Ride, success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        api.post("/ride", parameters: ride.toJSON(), success: { task, responseObject in
            guard let ridesJson = responseObject as? [[String: Any]] else {
                error(CaronaeError.invalidResponse)
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
            } catch let realmError {
                error(realmError)
            }
            
            success()
        }, failure: { _, err in
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
                    
                    NotificationService.instance.clearNotifications(forRideID: id)
                    self.updateActiveRides(success: {} , error: {_ in })
                } else {
                    NSLog("Ride with id %d not found locally in user's rides", id)
                }
            } catch let realmError {
                error(realmError)
            }
            
            success()
        }, failure: { _, err in
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
                    
                    NotificationService.instance.clearNotifications(forRideID: id)
                } else {
                    NSLog("Rides with routine id %d not found locally in user's rides", id)
                }
            } catch let realmError {
                error(realmError)
            }
            
            success()
        }, failure: { _, err in
            error(err)
        })
    }
    
    func deleteRoutine(withID id: Int, success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        api.delete("/ride/allFromRoutine/\(id)", parameters: nil, success: { task, responseObject in
            do {
                let realm = try Realm()
                let rides = realm.objects(Ride.self).filter("routineID == %@", id)
                if !rides.isEmpty {    
                    rides.forEach { ride in
                        NotificationService.instance.clearNotifications(forRideID: ride.id)
                    }
                    
                    try realm.write {
                        realm.delete(rides)
                    }
                } else {
                    NSLog("Ride with id %d not found locally in user's rides", id)
                }
            } catch let realmError {
                error(realmError)
            }
            
            success()
        }, failure: { _, err in
            error(err)
        })
    }
    
    func requestJoinOnRide(withID id: Int, success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        api.post("/ride/requestJoin", parameters: ["rideId": id], success: { task, responseObject in
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(RideRequest(rideID: id), update: true)
                }
            } catch let realmError {
                error(realmError)
            }
            
            success()
        }, failure: { _, err in
            error(err)
        })
    }
    
    func hasRequestedToJoinRide(withID id: Int) -> Bool {
        if let realm = try? Realm(), let _ = realm.object(ofType: RideRequest.self, forPrimaryKey: id) {
            return true
        }
        
        return false
    }
    
    func validateRideDate(ride: Ride, success: @escaping (_ valid: Bool, _ status: String) -> Void, error: @escaping (_ error: Error?) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: ride.date).components(separatedBy: " ")
        
        let params = [
            "date": dateString.first!,
            "time": dateString.last!,
            "going": ride.going
            ] as [String: Any]
        
        api.get("/ride/validateDuplicate", parameters: params, success: { _, responseObject in
            guard let response = responseObject as? [String: Any],
                let valid = response["valid"] as? Bool,
                let status = response["status"] as? String else {
                    error(nil)
                    return
            }
            
            success(valid, status)
        }, failure: { _, err in
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
            if accepted {
                do {
                    let realm = try Realm()
                    if let ride = realm.object(ofType: Ride.self, forPrimaryKey: rideID) {
                        try realm.write {
                            realm.add(user, update: true)
                            ride.riders.append(user)
                            ride.isActive = true
                        }
                    } else {
                        NSLog("Ride with id %d not found locally in user's rides", rideID)
                    }
                } catch let realmError {
                    error(realmError)
                }
            }

            success()
        }, failure: { _, err in
            error(err)
        })
    }
}
