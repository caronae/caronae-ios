import UIKit
import SKPhotoBrowser
import SDWebImage

class CaronaeImageViewer: UIViewController, SKPhotoBrowserDelegate {
    static let instance = CaronaeImageViewer()
    var profileImage: UIImageView!
    var images = [SKPhotoProtocol]()
    var url: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKCache.sharedCache.imageCache = CustomImageCache()
        
        SKPhotoBrowserOptions.displayPagingHorizontalScrollIndicator = false
        SKPhotoBrowserOptions.displayHorizontalScrollIndicator = false
        SKPhotoBrowserOptions.displayCounterLabel = false
        SKPhotoBrowserOptions.displayBackAndForwardButton = false
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayHorizontalScrollIndicator = false
        SKPhotoBrowserOptions.displayVerticalScrollIndicator = false
    }
    
    func present(pictureURL: String?){
        
        let photo = SKPhoto.photoWithImageURL(pictureURL!)
        photo.shouldCachePhotoURLImage = true
        
        let url = URL(string: pictureURL!)
        let complated: SDExternalCompletionBlock = { (image, error, cacheType, imageURL) -> Void in
            guard let url = imageURL?.absoluteString else { return }
            SKCache.sharedCache.setImage(image!, forKey: url)
        }
        
        if let topViewController = UIApplication.shared.topViewController() {
            let browser = SKPhotoBrowser(photos: [photo])
            browser.initializePageIndex(0)
            topViewController.present(browser, animated: true, completion: {})
        }
    }
}

class CustomImageCache: SKImageCacheable {
    var cache: SDImageCache
    
    init(){
        let cache = SDImageCache(namespace:"profileImageZoomCache")
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
