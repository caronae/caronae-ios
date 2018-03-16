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
}
