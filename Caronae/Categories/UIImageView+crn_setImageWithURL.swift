import SDWebImage

extension UIImageView {
    func crn_setImage(with url: URL?, completed completionHandler: (() -> Void)? = nil) {
        self.sd_setImage(with: url,
                         placeholderImage: UIImage(named: CaronaePlaceholderProfileImage),
                         options: .retryFailed) { image, error, cacheType, url in
                            if cacheType == .none {
                                self.alpha = 0.5
                                UIView.animate(withDuration: 0.3, animations: {
                                    self.alpha = 1.0
                                })
                            } else {
                                self.alpha = 1.0
                            }
                            
                            completionHandler?()
        }
    }
}
