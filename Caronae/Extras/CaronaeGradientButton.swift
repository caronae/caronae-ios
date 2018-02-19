import UIKit

@IBDesignable
class CaronaeGradientButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp() {
        backgroundColor = .clear
        
        let gradient = CAGradientLayer()
        
        gradient.frame = bounds
        gradient.cornerRadius = 10
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        gradient.colors = [UIColor.caronaeRed.cgColor, UIColor.caronaePink.cgColor]
        
        layer.insertSublayer(gradient, at: 0)
    }
}


extension UIColor {
    final class var caronaeRed: UIColor {
        return UIColor(red: 0.890, green: 0.145, blue: 0.165, alpha: 1)
    }
    
    final class var caronaePink: UIColor {
        return UIColor(red: 0.898, green:0.349, blue:0.620, alpha:1)
    }
    
    final class var caronaeOrange: UIColor {
        return UIColor(red: 0.906, green:0.424, blue:0.114, alpha:1)
    }
    
    final class var caronaeBrown: UIColor {
        return UIColor(red: 0.353, green:0.157, blue:0.094, alpha:1)
    }
    
    final class var caronaeGreen: UIColor {
        return UIColor(red: 0.114, green:0.655, blue:0.365, alpha:1)
    }
    
    final class var caronaeBlue: UIColor {
        return UIColor(red: 0.125, green:0.145, blue:0.467, alpha:1)
    }
    
    final class var caronaeGray: UIColor {
        return UIColor(white: 0.541, alpha:1)
    }
}
