import Alamofire

class CaronaeAPIHTTPSessionManager: SessionManager {
    static let instance = CaronaeAPIHTTPSessionManager()
    let caronaeAPIBaseURL = URL(string: CaronaeAPIBaseURLString)!

    private init() {
        super.init(configuration: .default, delegate: SessionDelegate())

        self.adapter = CaronaeAccessTokenAdapter()
        self.startRequestsImmediately = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Mimicking AFNetwork methods
    public func get(_ url: String, parameters: Parameters?, progress: DataRequest.ProgressHandler?, success: ((URLSessionDataTask?, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) {
        let fullUrl = self.caronaeAPIBaseURL.absoluteString.appending(url)
        let request = self.request(fullUrl, parameters: parameters)

        if let progress = progress {
            request.downloadProgress(closure: progress)
        }
        request.responseCaronae { response in
            success?(request.task as? URLSessionDataTask, response.result.value)
        }
        request.resume()
    }

    public func post(_ url: String, parameters: Parameters?, constructingBodyWith: ((MultipartFormData) -> Void)? = nil, progress: DataRequest.ProgressHandler?, success: ((URLSessionDataTask?, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) {
        let fullUrl = self.caronaeAPIBaseURL.absoluteString.appending(url)

        if let constructingBodyWith = constructingBodyWith {
            self.upload(multipartFormData: constructingBodyWith, to: fullUrl, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseCaronae { response in
                        success?(upload.task as? URLSessionDataTask, response.result.value)
                    }
                    upload.resume()
                case .failure(let encodingError):
                    print(encodingError)
                }
            })
        } else {
            let request = self.request(fullUrl, method: .post, parameters: parameters)
            if let progress = progress {
                request.downloadProgress(closure: progress)
            }
            request.responseCaronae { response in
                success?(request.task as? URLSessionDataTask, response.result.value)
            }
            request.resume()
        }
    }

    public func put(_ url: String, parameters: Parameters?, success: ((URLSessionDataTask?, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) {
        let fullUrl = self.caronaeAPIBaseURL.absoluteString.appending(url)
        let request = self.request(fullUrl, method: .put, parameters: parameters)
        request.responseCaronae { response in
            success?(request.task as? URLSessionDataTask, response.result.value)
        }
        request.resume()
    }

    public func delete(_ url: String, parameters: Parameters?, success: ((URLSessionDataTask?, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) {
        let fullUrl = self.caronaeAPIBaseURL.absoluteString.appending(url)

        let request = self.request(fullUrl, method: .delete, parameters: parameters)
        request.responseCaronae { response in
            success?(request.task as? URLSessionDataTask, response.result.value)
        }
        request.resume()
    }
}
