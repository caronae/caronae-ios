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
        // Add user token to the HTTP headers if the user is logged in
        if let userToken = UserController.sharedInstance().userToken {
            self.setValue(userToken, forHTTPHeaderField: "token")
        } else {
            self.setValue(nil, forHTTPHeaderField: "token")
        }
        // Add user FB token to the HTTP headers
        if let userFBToken = UserController.sharedInstance().userFBToken {
            self.setValue(userFBToken, forHTTPHeaderField: "Facebook-Token")
        } else {
            self.setValue(nil, forHTTPHeaderField: "Facebook-Token")
        }
        
        return super.request(withMethod: method, urlString: URLString, parameters: parameters, error: error)
    }
}
