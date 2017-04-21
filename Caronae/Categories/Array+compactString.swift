import Foundation

extension Array where Iterator.Element == String {
    func compactString() -> String {
        var label = String()
        for i in 0..<self.count {
            if i > 2 {
                label = String(format: "%@ + %lu", label, self.count-i)
                break;
            }
            label = label.appending(self[i])
            if i < self.count - 1 && i < 2 {
                label = label.appending(", ")
            }
        }
        return label
    }
}

extension NSArray {
    func compactString() -> String {
        var label = String()
        for i in 0..<self.count {
            if i > 2 {
                label = String(format: "%@ + %lu", label, self.count-i)
                break;
            }
            label = label.appending(self[i] as! String)
            if i < self.count - 1 && i < 2 {
                label = label.appending(", ")
            }
        }
        return label
    }
}
