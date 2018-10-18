import Alamofire

class CaronaeAPIHTTPSessionManager: SessionManager {
    static let instance = CaronaeAPIHTTPSessionManager()
    let caronaeAPIBaseURL = URL(string: CaronaeAPIBaseURLString)!

    private init() {
        super.init(configuration: .default, delegate: SessionDelegate())
        self.startRequestsImmediately = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func getHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = [:]
        let userService = UserService.instance
        if let jwtToken = userService.jwtToken {
            headers.updateValue("Bearer \(jwtToken)", forKey: "Authorization")
        } else {
            if let userToken = userService.userToken {
                headers.updateValue(userToken, forKey: "token")
            }
        }
        if let userFacebookToken = userService.userFacebookToken {
            headers.updateValue(userFacebookToken, forKey: "Facebook-Token")
        }

        return headers
    }

    fileprivate func parseResponse(_ response: (DataResponse<Any>)) {
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
        let fullUrl = self.caronaeAPIBaseURL.absoluteString.appending(url)
        let request = self.request(fullUrl, parameters: parameters, headers: self.getHeaders())

        if let progress = progress {
            request.downloadProgress(closure: progress)
        }
        request.responseJSON { response in
            self.parseResponse(response)
            success?(request.task as? URLSessionDataTask, response.result.value)
        }
        request.resume()
    }

    public func post(_ url: String, parameters: Parameters?, constructingBodyWith: @escaping ((MultipartFormData) -> Void) = { _ in }, progress: DataRequest.ProgressHandler?, success: ((URLSessionDataTask?, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) {
        let fullUrl = self.caronaeAPIBaseURL.absoluteString.appending(url)

        let request = self.request(fullUrl, method: .post, parameters: parameters, headers: self.getHeaders())

//        self.upload(multipartFormData: constructingBodyWith, to: self.caronaeAPIBaseURL.appendingPathExtension(url), encodingCompletion: nil)

        if let progress = progress {
            request.downloadProgress(closure: progress)
        }
        request.responseJSON { response in
            self.parseResponse(response)
            success?(request.task as? URLSessionDataTask, response.result.value)
        }
        request.resume()
    }

    public func put(_ url: String, parameters: Parameters?, success: ((URLSessionDataTask?, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) {
        let fullUrl = self.caronaeAPIBaseURL.absoluteString.appending(url)
        let request = self.request(fullUrl, method: .put, parameters: parameters, headers: self.getHeaders())
        request.responseJSON { response in
            self.parseResponse(response)
            success?(request.task as? URLSessionDataTask, response.result.value)
        }
        request.resume()
    }

    public func delete(_ url: String, parameters: Parameters?, success: ((URLSessionDataTask?, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) {
        let fullUrl = self.caronaeAPIBaseURL.absoluteString.appending(url)

        let request = self.request(fullUrl, method: .delete, parameters: parameters, headers: self.getHeaders())
        request.responseJSON { response in
            self.parseResponse(response)
            success?(request.task as? URLSessionDataTask, response.result.value)
        }
        request.resume()
    }
}
