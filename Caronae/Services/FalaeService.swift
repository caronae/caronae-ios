class FalaeService {
    static let instance = FalaeService()
    private let api = CaronaeAPIHTTPSessionManager.instance
    
    private init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    func sendMessage(subject: String, message: String, success: @escaping () -> Void, error: @escaping (_ error: Error) -> Void) {
        let params = [
            "subject": subject,
            "message": message
            ]
        
        let request = api.request("/api/v1/falae/messages", method: .post, parameters: params)
        request.validate().responseCaronae { response in
            switch response.result {
            case .success:
                success()
            case .failure(let err):
                error(err)
            }
        }
    }
}
