extension String {
    
    /// Returns only the digits of any string
    var onlyDigits: String {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
    /// Returns only the letters of any string
    var onlyLetters: String {
        return self.components(separatedBy: CharacterSet.letters.inverted).joined()
    }
    
    /// Returns only the non-alphanumeric characters of any string
    var notAlphanumerics: String {
        return self.components(separatedBy: CharacterSet.alphanumerics).joined()
    }
    
    /// Returns true iff the string is composed only of letters
    var isAlpha: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
}
