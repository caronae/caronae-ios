import SKPhotoBrowser
import SDWebImage

class CaronaeImageViewer: SKPhotoBrowserDelegate {
    static let instance = CaronaeImageViewer()

    private init() {
        SKCache.sharedCache.imageCache = CustomImageCache()
        SKPhotoBrowserOptions.displayAction = false
    }
    
    func present(pictureURL: String){
        let photo = SKPhoto.photoWithImageURL(pictureURL)
        photo.shouldCachePhotoURLImage = true
        
        if let topViewController = UIApplication.shared.topViewController() {
            let browser = SKPhotoBrowser(photos: [photo])
            topViewController.present(browser, animated: true)
        }
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
