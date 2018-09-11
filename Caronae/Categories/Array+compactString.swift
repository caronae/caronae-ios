extension Array where Iterator.Element == String {
    func compactString() -> String {
        var label = String()
        for index in 0..<self.count {
            if index > 2 {
                label = String(format: "%@ + %lu", label, self.count - index)
                break
            }
            
            label = label.appending(self[index])
            if index < self.count - 1 && index < 2 {
                label = label.appending(", ")
            }
        }
        return label
    }
}
