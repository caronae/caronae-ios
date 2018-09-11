extension Array where Iterator.Element == String {
    func sortedCaseInsensitive() -> [String] {
        return self.sorted { $0.caseInsensitiveCompare($1) == .orderedAscending }
    }
}
