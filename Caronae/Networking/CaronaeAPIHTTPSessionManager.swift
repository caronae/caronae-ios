import AFNetworking

class CaronaeAPIHTTPSessionManager: AFHTTPSessionManager {
    static let instance = CaronaeAPIHTTPSessionManager()

    private init() {
        let caronaeAPIBaseURL = URL(string: CaronaeAPIBaseURLString)
        super.init(baseURL: caronaeAPIBaseURL, sessionConfiguration: .default)
        
        requestSerializer = CaronaeAPIRequestSerializer()
        responseSerializer = CaronaeAPIResponseSerializer()
        requestSerializer.timeoutInterval = 30
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
