import Foundation

extension NSDate {
    /// Gets the next full hour from current date. For example, if now is 16:16:45, returns 17:00:00.
    ///
    /// - returns: NSDate with next full hour (current hour + 1), 0 minutes and 0 seconds.
    class var nextHour: NSDate {
        let gregorian = Calendar(identifier: .gregorian)
        let now = Date()
        var components = gregorian.dateComponents([.year, .month, .day, .hour], from: now)
        components.hour! += 1
        return gregorian.date(from: components)! as NSDate
    }
    
    /// Gets the current full hour from current date. For example, if now is 16:16:45, returns 16:00:00.
    ///
    /// - returns: NSDate with current full hour (current hour), 0 minutes and 0 seconds.
    class var currentHour: NSDate {
        let gregorian = Calendar(identifier: .gregorian)
        let now = Date()
        let components = gregorian.dateComponents([.year, .month, .day, .hour], from: now)
        return gregorian.date(from: components)! as NSDate
    }
    
    /// Gets the current full hour:minutes from current date plus the argument in minutes.
    ///
    /// - returns: NSDate with currente full hour:minutes + minutes.
    class func currentTimePlus(_ minutes: Int) -> NSDate {
        let gregorian = Calendar(identifier: .gregorian)
        let now = Date()
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        components.minute! += minutes
        return gregorian.date(from: components)! as NSDate
    }
}

extension Date {
    /// Gets the next full hour from current date. For example, if now is 16:16:45, returns 17:00:00.
    ///
    /// - returns: NSDate with next full hour (current hour + 1), 0 minutes and 0 seconds.
    static var nextHour: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let now = Date()
        var components = gregorian.dateComponents([.year, .month, .day, .hour], from: now)
        components.hour! += 1
        return gregorian.date(from: components)!
    }
    
    /// Gets the current full hour from current date. For example, if now is 16:16:45, returns 16:00:00.
    ///
    /// - returns: NSDate with current full hour (current hour), 0 minutes and 0 seconds.
    static var currentHour: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let now = Date()
        let components = gregorian.dateComponents([.year, .month, .day, .hour], from: now)
        return gregorian.date(from: components)!
    }
    
    /// Gets the current full hour:minutes from current date plus the argument in minutes.
    ///
    /// - returns: NSDate with currente full hour:minutes + minutes.
    static func currentTimePlus(minutes: Int) -> Date {
        let gregorian = Calendar(identifier: .gregorian)
        let now = Date()
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        components.minute! += minutes
        return gregorian.date(from: components)!
    }
}
