extension UIViewController {
    
    public func isVisible() -> Bool {
        return self.isViewLoaded && (self.view.window != nil)
    }
}
