import AFNetworking

class CaronaeAPIResponseSerializer: AFJSONResponseSerializer {
    override func responseObject(for response: URLResponse?, data: Data?, error: NSErrorPointer) -> Any? {
        let responseObject = super.responseObject(for: response, data: data, error: error)
        let response = response as? HTTPURLResponse
        let userService = UserService.instance

        if let error = error,
            let response = response,
            response.statusCode == 401 {
            error.pointee = CaronaeError.invalidCredentials

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

        return responseObject
    }
}
