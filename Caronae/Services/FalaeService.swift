import Foundation

class FalaeService: NSObject {
    static let instance = FalaeService()
    private let api = CaronaeAPIHTTPSessionManager.instance
    
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    func sendMessage(subject: String, message: String, success: @escaping () -> Void, error: @escaping (_ error: Error?) -> Void) {
        let params = [
            "subject": subject,
            "message": message,
            ]
        
        api.post("/falae/sendMessage", parameters: params, success: { _, _ in
            success()
        }, failure: { _, err in
            error(err)
        })
    }
}

