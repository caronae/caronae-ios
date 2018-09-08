class FalaeService {
    static let instance = FalaeService()
    private let api = CaronaeAPIHTTPSessionManager.instance
    
    private init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    func sendMessage(subject: String, message: String, success: @escaping () -> Void, error: @escaping (_ error: Error?) -> Void) {
        let params = [
            "subject": subject,
            "message": message,
            ]
        
        api.post("/api/v1/falae/messages", parameters: params, progress: nil, success: { _, _ in
            success()
        }, failure: { _, err in
            error(err)
        })
    }
}
