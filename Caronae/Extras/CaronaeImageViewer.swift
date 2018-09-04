import SKPhotoBrowser
import SDWebImage

class CaronaeImageViewer {
    static let instance = CaronaeImageViewer()

    private init() {
        SKCache.sharedCache.imageCache = CustomImageCache()
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.bounceAnimation = true
        SKPhotoBrowserOptions.displayStatusbar = true
    }
    
    func present(pictureURL: String, animatedFrom view: UIImageView) {
        let photo = SKPhoto.photoWithImageURL(pictureURL)
        photo.shouldCachePhotoURLImage = true
        
        if let topViewController = UIApplication.shared.topViewController() {
            let browser = CustomSKPhotoBrowser(originImage: view.image ?? UIImage(), photos: [photo], animatedFromView: view)
            topViewController.present(browser, animated: true)
        }
    }
}


// MARK: Custom classes

class CustomSKPhotoBrowser: SKPhotoBrowser {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


class CustomImageCache: SKImageCacheable {
    var cache: SDImageCache
    
    init() {
        let cache = SDImageCache.shared()
        self.cache = cache
    }
    
    func imageForKey(_ key: String) -> UIImage? {
        guard let image = cache.imageFromDiskCache(forKey: key) else { return nil }
        return image
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.store(image, forKey: key)
    }
    
    func removeImageForKey(_ key: String) {
    }
    
    func removeAllImages() {
    }
}
