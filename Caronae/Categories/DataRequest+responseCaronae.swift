import Alamofire

extension DataRequest {
    static func caronaeResponseSerializer(options: JSONSerialization.ReadingOptions = .allowFragments) -> DataResponseSerializer<Any> {
        return DataResponseSerializer { _, response, data, error in
            
            let result = Request.serializeResponseJSON(options: options, response: response, data: data, error: error)
            guard let response = response else {
                return result
            }
            
            if response.statusCode == 401 {
                // Invalid credentials
                DispatchQueue.main.async {
                    let userService = UserService.instance
                    if userService.user != nil {
                        userService.signOut(force: true)
                    }
                }
            }
            
            if let authorizationHeader = response.allHeaderFields["Authorization"] as? String,
                let jwtToken = authorizationHeader.components(separatedBy: "Bearer ").last {
                NSLog("New token returned from API")
                let userService = UserService.instance
                userService.jwtToken = jwtToken
                userService.userToken = nil
            }
            
            return result
        }
    }
    
    @discardableResult
    func responseCaronae(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        completionHandler: @escaping (DataResponse<Any>) -> Void)
        -> Self {
            return response(
                queue: queue,
                responseSerializer: DataRequest.caronaeResponseSerializer(options: options),
                completionHandler: completionHandler
            )
    }
}
