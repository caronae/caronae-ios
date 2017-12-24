import RealmSwift
import ObjectMapper
import ObjectMapper_Realm

class Ride: Object, Mappable {
    @objc dynamic var id: Int = 0
    @objc dynamic var region: String!
    @objc dynamic var neighborhood: String!
    @objc dynamic var place: String!
    @objc dynamic var hub: String!
    @objc dynamic var route: String!
    @objc dynamic var notes: String!
    @objc dynamic var going: Bool = true
    @objc dynamic var slots: Int = 0
    @objc dynamic var date: Date! = Date()
    @objc dynamic var isActive: Bool = false
    @objc dynamic var isPending: Bool = false
    
    @objc dynamic var weekDays: String?
    @objc dynamic var repeatsUntil: Date?
    var routineID = RealmOptional<Int>()
    
    @objc dynamic var driver: User!
    var riders = List<User>()
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["_dateString", "_timeString"]
    }
    
    func mapping(map: Map) {
        let dateDateformatter = DateFormatter()
        dateDateformatter.dateFormat = "yyyy-MM-dd"
        let dateFormatter = DateFormatterTransform(dateFormatter: dateDateformatter)
        
        id <- map["id"]
        region <- map["myzone"]
        neighborhood <- map["neighborhood"]
        place <- map["place"]
        hub <- map["hub"]
        route <- map["route"]
        notes <- map["description"]
        going <- map["going"]
        slots <- map["slots"]
        
        _dateString <- map["mydate"]
        _timeString <- map["mytime"]
        
        routineID.value <- map["routine_id"]
        weekDays <- map["week_days"]
        repeatsUntil <- (map["repeats_until"], dateFormatter)
        
        driver <- map["driver"]
        riders <- (map["riders"], ListTransform<User>())
    }
    
    @objc var title: String {
        if going {
            return String(format: "%@ → %@", neighborhood, hub)
        } else {
            return String(format: "%@ → %@", hub, neighborhood)
        }
    }
    
    @objc var isRoutine: Bool {
        return routineID.value != nil
    }
    
    @objc var availableSlots: Int {
        return slots - riders.count
    }
    
    private var _dateString: String? {
        get {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(for: date)
        }
        set {
            updateDate(newValue)
        }
    }
    
    private func updateDate(_ newDate: String?) {
        guard let dateString = newDate, let timeString = _timeString else { return }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.date = formatter.date(from: dateString + " " + timeString)
    }
    
    private var _timeString: String? {
        get {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "HH:mm:ss"
            return formatter.string(for: date)
        }
        set {
            updateTime(newValue)
        }
    }
    
    private func updateTime(_ newTime: String?) {
        guard let dateString = _dateString, let timeString = newTime else { return }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.date = formatter.date(from: dateString + " " + timeString)
    }
}

