import Foundation

extension NSDate {
    /// Determine if the date is in the future.
    ///
    /// - returns: true if date is in the future or false if now or in the past
    public func isInTheFuture() -> Bool {
        return self.timeIntervalSinceNow > 0
    }
}
