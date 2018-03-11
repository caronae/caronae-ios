import AFNetworking

class CaronaeAPIRequestSerializer: AFJSONRequestSerializer {
    override func request(withMethod method: String, urlString URLString: String, parameters: Any?, error: NSErrorPointer) -> NSMutableURLRequest {
        let userService = UserService.instance

        if let jwtToken = userService.jwtToken {
            self.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        } else {
            self.setValue(userService.userToken, forHTTPHeaderField: "token")
        }

        self.setValue(userService.userFacebookToken, forHTTPHeaderField: "Facebook-Token")

        return super.request(withMethod: method, urlString: URLString, parameters: parameters, error: error)
    }
}
