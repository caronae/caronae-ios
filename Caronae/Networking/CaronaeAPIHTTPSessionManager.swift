import Alamofire

class CaronaeAPIHTTPSessionManager: SessionManager {
    static let instance = CaronaeAPIHTTPSessionManager()
    let caronaeAPIBaseURL = URL(string: CaronaeAPIBaseURLString)!
    private var headers: HTTPHeaders = [:]

    private init() {
        super.init(configuration: .default, delegate: SessionDelegate())

        let userService = UserService.instance
        if let jwtToken = userService.jwtToken {
            headers.updateValue("Bearer \(jwtToken)", forKey: "Authorization")
        } else {
            headers.updateValue(userService.userToken!, forKey: "token")
        }
        headers.updateValue(userService.userFacebookToken!, forKey: "Facebook-Token")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func parseResponse(_ response: (DataResponse<Data>)) {
        let userService = UserService.instance

        if let error = response.error as! NSErrorPointer,
            let response = response.response,
            response.statusCode == 401 {
            error.pointee = CaronaeError.invalidCredentials

            DispatchQueue.main.async {
                if userService.user != nil {
                    userService.signOut(force: true)
                }
            }
        }

        if let response = response.response,
            let authorizationHeader = response.allHeaderFields["Authorization"] as? String,
            let jwtToken = authorizationHeader.components(separatedBy: "Bearer ").last {
            NSLog("New token returned from API")
            userService.jwtToken = jwtToken
            userService.userToken = nil
        }
    }

    // MARK: - Mimicking AFNetwork methods
    public func get(_ url: String, parameters: Parameters?, progress: DataRequest.ProgressHandler?, success: ((URLSessionDataTask?, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) {
        let request = self.request(self.caronaeAPIBaseURL.appendingPathExtension(url), parameters: parameters, headers: headers)
        if let progress = progress {
            request.downloadProgress(closure: progress)
        }
        request.responseData { response in
            self.parseResponse(response)
            success?(request.task as? URLSessionDataTask, response.data)
        }
        request.resume()
    }

    public func post(_ url: String, parameters: Parameters?, constructingBodyWith: @escaping ((MultipartFormData) -> Void) = { _ in }, progress: DataRequest.ProgressHandler?, success: ((URLSessionDataTask?, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) {
        let request = self.request(self.caronaeAPIBaseURL.appendingPathExtension(url), method: .post, parameters: parameters, headers: headers)
        
        self.upload(multipartFormData: constructingBodyWith, to: self.caronaeAPIBaseURL.appendingPathExtension(url), encodingCompletion: nil)

        if let progress = progress {
            request.downloadProgress(closure: progress)
        }
        request.responseData { response in
            self.parseResponse(response)
            success?(request.task as? URLSessionDataTask, response.data)
        }
        request.resume()
    }

    public func put(_ url: String, parameters: Parameters?, success: ((URLSessionDataTask?, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) {
        let request = self.request(self.caronaeAPIBaseURL.appendingPathExtension(url), method: .put, parameters: parameters, headers: headers)
        request.responseData { response in
            self.parseResponse(response)
            success?(request.task as? URLSessionDataTask, response.data)
        }
        request.resume()
    }

    public func delete(_ url: String, parameters: Parameters?, success: ((URLSessionDataTask?, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) {
        let request = self.request(self.caronaeAPIBaseURL.appendingPathExtension(url), method: .delete, parameters: parameters, headers: headers)
        request.responseData { response in
            self.parseResponse(response)
            success?(request.task as? URLSessionDataTask, response.data)
        }
        request.resume()
    }
}
