extension String {
    var isValidEmail: Bool {
        let emailRegex = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    var isValidCarPlate: Bool {
        let plateRegex = "^[a-zA-Z]{3}-[0-9]{4}$"
        let plateTest = NSPredicate(format: "SELF MATCHES %@", plateRegex)
        return plateTest.evaluate(with: self)
    }
    
    /// Returns only the numbers of phone format "(###) #####-####"
    var phoneWithoutMask: String {
        var phone = self
        phone.remove(at: phone.index(phone.startIndex, offsetBy: 11))
        phone.remove(at: phone.index(phone.startIndex, offsetBy: 5))
        phone.remove(at: phone.index(phone.startIndex, offsetBy: 4))
        phone.removeFirst()
        return phone
    }
}
