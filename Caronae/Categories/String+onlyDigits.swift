extension String {
    
    /// Returns only the digits of any string
    var onlyDigits: String {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
