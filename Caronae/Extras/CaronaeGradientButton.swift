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
        tintColor = .white
        
        let gradient = CAGradientLayer()
        
        gradient.frame = bounds
        gradient.cornerRadius = 10
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        gradient.colors = [UIColor.caronaeRed.cgColor, UIColor.caronaePink.cgColor]
        
        if let imageLayer = imageView?.layer {
            layer.insertSublayer(gradient, below: imageLayer)
        } else {
            layer.insertSublayer(gradient, at: 0)
        }
    }
}
