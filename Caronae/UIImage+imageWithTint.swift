import UIKit

extension UIImage {
    func imageWithTintColor(color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPointZero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        self.drawInRect(rect)
        color.setFill()
        CGContextSetBlendMode(context, CGBlendMode.SourceAtop)
        CGContextFillRect(context, rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func imageWithRed(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage {
        let rect = CGRect(origin: CGPointZero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        self.drawInRect(rect)
        CGContextSetRGBFillColor(context, red, green, blue, alpha)
        CGContextSetBlendMode(context, CGBlendMode.SourceAtop)
        CGContextFillRect(context, rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
