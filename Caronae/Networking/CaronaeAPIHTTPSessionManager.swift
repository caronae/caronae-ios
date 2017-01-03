import AFNetworking

class CaronaeAPIHTTPSessionManager: AFHTTPSessionManager {
    static let instance = CaronaeAPIHTTPSessionManager()
   
    private init() {
        super.init(baseURL: URL(string: CaronaeAPIBaseURL), sessionConfiguration: URLSessionConfiguration.default)
        requestSerializer = CaronaeRequestSerializer()
        responseSerializer = AFJSONResponseSerializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CaronaeRequestSerializer: AFJSONRequestSerializer {
    override func request(withMethod method: String, urlString URLString: String, parameters: Any?, error: NSErrorPointer) -> NSMutableURLRequest {
        // Add user token to the HTTP headers
        self.setValue(UserController.sharedInstance().userToken, forHTTPHeaderField: "token")

        // Add user FB token to the HTTP headers
        self.setValue(UserController.sharedInstance().userFBToken, forHTTPHeaderField: "Facebook-Token")
        
        return super.request(withMethod: method, urlString: URLString, parameters: parameters, error: error)
    }
}
