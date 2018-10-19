import Alamofire

extension DataRequest {
    static func caronaeResponseSerializer() -> DataResponseSerializer<Any> {
        return DataResponseSerializer { _, response, data, error in
            let result = Request.serializeResponseJSON(options: .allowFragments, response: response, data: data, error: nil)

            guard case let .success(validData) = result else {
                return .failure(error!)
            }

            let userService = UserService.instance

            if let error = error as? AFError,
                let response = response,
                response.statusCode == 401,
                let pointer = error.underlyingError as! NSErrorPointer {
                pointer.pointee = CaronaeError.invalidCredentials

                DispatchQueue.main.async {
                    if userService.user != nil {
                        userService.signOut(force: true)
                    }
                }
            }

            if let response = response,
                let authorizationHeader = response.allHeaderFields["Authorization"] as? String,
                let jwtToken = authorizationHeader.components(separatedBy: "Bearer ").last {
                NSLog("New token returned from API")
                userService.jwtToken = jwtToken
                userService.userToken = nil
            }

            return .success(validData)
        }
    }

    @discardableResult
    func responseCaronae(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Any>) -> Void)
        -> Self {
            return response(
                queue: queue,
                responseSerializer: DataRequest.caronaeResponseSerializer(),
                completionHandler: completionHandler
            )
    }
}
