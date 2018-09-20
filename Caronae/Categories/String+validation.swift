extension String {
    var isValidEmail: Bool {
        let emailRegex = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    var isValidCarPlate: Bool {
        let brazilianPlateRegex = "^[A-Z]{3}-[0-9]{4}$"
        let mercosulPlateRegex = "^(?=(?:.*[0-9]){3})(?=(?:.*[A-Z]){4})[A-Z0-9]{7}$"
        let brazilianPlateTest = NSPredicate(format: "SELF MATCHES %@", brazilianPlateRegex)
        let mercosulPlateTest = NSPredicate(format: "SELF MATCHES %@", mercosulPlateRegex)
        return brazilianPlateTest.evaluate(with: self) || mercosulPlateTest.evaluate(with: self)
    }
}
