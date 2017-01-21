import AFNetworking

class CaronaeAPIHTTPSessionManager: AFHTTPSessionManager {
    static let instance = CaronaeAPIHTTPSessionManager()
   
    private init() {
        super.init(baseURL: URL(string: CaronaeAPIBaseURL), sessionConfiguration: URLSessionConfiguration.default)
        requestSerializer = CaronaeAPIRequestSerializer()
        responseSerializer = CaronaeAPIResponseSerializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CaronaeAPIRequestSerializer: AFJSONRequestSerializer {
    override func request(withMethod method: String, urlString URLString: String, parameters: Any?, error: NSErrorPointer) -> NSMutableURLRequest {
        // Add user token to the HTTP headers
        self.setValue(UserService.instance.userToken, forHTTPHeaderField: "token")

        // Add user FB token to the HTTP headers
        self.setValue(UserService.instance.userFacebookToken, forHTTPHeaderField: "Facebook-Token")
        
        return super.request(withMethod: method, urlString: URLString, parameters: parameters, error: error)
    }
}


class CaronaeAPIResponseSerializer: AFJSONResponseSerializer {
    override func responseObject(for response: URLResponse?, data: Data?, error: NSErrorPointer) -> Any? {
        let responseObject = super.responseObject(for: response, data: data, error: error)
        if let error = error,
            let response = response as? HTTPURLResponse,
            (response.statusCode == 403 || response.statusCode == 401) {
            error.pointee = CaronaeError.invalidCredentials
        }
        return responseObject
    }
}
