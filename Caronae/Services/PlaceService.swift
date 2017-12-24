import Foundation
import RealmSwift

class PlaceService: NSObject {
    @objc static let instance = PlaceService()
    let api = CaronaeAPIHTTPSessionManager.instance
    
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }

    func getCampi(hubTypeDirection: HubSelectionViewController.HubTypeDirection, success: @escaping (_ campi: [String], _ options: [String: [String]], _ colors: [String: UIColor], _ shouldReload: Bool) -> Void, error: @escaping (_ error: Error) -> Void) {
        if let realm = try? Realm(), realm.objects(Place.self).isEmpty {
            updatePlaces(success: {
                let (campi, options, colors) = self.loadCampiFromRealm(hubTypeDirection: hubTypeDirection)
                success(campi, options, colors, true)
            }, error: { err in
                error(err)
                return
            })
        } else {
            let (campi, options, colors) = self.loadCampiFromRealm(hubTypeDirection: hubTypeDirection)
            success(campi, options, colors, false)
        }
    }
    
    func loadCampiFromRealm(hubTypeDirection: HubSelectionViewController.HubTypeDirection) -> ([String], [String: [String]], [String: UIColor]) {
        let realm = try! Realm()
        let campusObjects = realm.objects(Campus.self)
        let campi = campusObjects.flatMap { $0.name }.sorted()
        var options = [String: [String]]()
        if hubTypeDirection == .hubs {
            campusObjects.forEach { options[$0.name] = $0.hubs }
        } else {
            campusObjects.forEach { options[$0.name] = $0.centers }
        }
        var colors = [String: UIColor]()
        campusObjects.forEach { colors[$0.name] = $0.color }
            
        return (campi, options, colors)
    }
    
    func getZones(success: @escaping (_ zones: [String], _ options: [String: [String]], _ colors: [String: UIColor], _ shouldReload: Bool) -> Void, error: @escaping (_ error: Error) -> Void) {
        if let realm = try? Realm(), realm.objects(Place.self).isEmpty {
            updatePlaces(success: {
                let (zones, options, colors) = self.loadZonesFromRealm()
                success(zones, options, colors, true)
            }, error: { err in
                error(err)
                return
            })
        } else {
            let (zones, options, colors) = self.loadZonesFromRealm()
            success(zones, options, colors, false)
        }
    }
    
    func loadZonesFromRealm() -> ([String], [String: [String]], [String: UIColor]) {
        let realm = try! Realm()
        let zoneObjects = realm.objects(Zone.self)
        var zones = zoneObjects.flatMap { $0.name }.sorted()
        var options = [String: [String]]()
        zoneObjects.forEach { options[$0.name] = $0.neighborhoods }
        var colors = [String: UIColor]()
        zoneObjects.forEach { colors[$0.name] = $0.color }
            
        zones.append(CaronaeOtherZoneText)
        colors[CaronaeOtherZoneText] = OtherZoneColor
            
        return (zones, options, colors)
    }
    
    @objc func color(forZone zone: String) -> UIColor {
        if zone == CaronaeOtherZoneText {
            return OtherZoneColor
        }
        let realm = try! Realm()
        return realm.objects(Zone.self).filter("name == %@", zone).first?.color ?? .darkGray
    }
    
    func updatePlaces(success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        api.get("/places", parameters: nil, success: { task, responseObject in
            guard let response = responseObject as? [String: Any],
                let campiJson = response["campi"] as? [[String: Any]],
                let zonesJson = response["zones"] as? [[String: Any]] else {
                    error(CaronaeError.invalidResponse)
                    return
            }
            
            let campi = campiJson.flatMap { Campus(JSON: $0) }
            let zones = zonesJson.flatMap { Zone(JSON: $0) }
            
            do {
                let realm = try Realm()
                // Clear old places and add new ones
                try realm.write {
                    realm.delete(realm.objects(Campus.self))
                    realm.delete(realm.objects(Zone.self))
                    realm.delete(realm.objects(Place.self))
                    realm.add(campi)
                    realm.add(zones)
                }
            } catch let realmError {
                error(realmError)
            }
            
            success()
        }, failure: { _, err in
            error(err)
        })
    }
}
