extension Date {
    /// Gets the next full hour from current date. For example, if now is 16:16:45, returns 17:00:00.
    ///
    /// - returns: Date with next full hour (current hour + 1), 0 minutes and 0 seconds.
    static var nextHour: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let now = Date()
        var components = gregorian.dateComponents([.year, .month, .day, .hour], from: now)
        components.hour! += 1
        return gregorian.date(from: components)!
    }
    
    /// Gets the current full hour from current date. For example, if now is 16:16:45, returns 16:00:00.
    ///
    /// - returns: Date with current full hour (current hour), 0 minutes and 0 seconds.
    static var currentHour: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let now = Date()
        let components = gregorian.dateComponents([.year, .month, .day, .hour], from: now)
        return gregorian.date(from: components)!
    }
    
    /// Gets the current hour:minutes from current date plus the argument in minutes.
    ///
    /// - returns: Date with currente hour:minutes + minutes.
    static func currentTimePlus(minutes: Int) -> Date {
        let gregorian = Calendar(identifier: .gregorian)
        let now = Date()
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        components.minute! += minutes
        return gregorian.date(from: components)!
    }
}
