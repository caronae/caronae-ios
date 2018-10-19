import Alamofire

class CaronaeAccessTokenAdapter: RequestAdapter {

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        let userService = UserService.instance
        if let jwtToken = userService.jwtToken {
            urlRequest.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        } else {
            if let userToken = userService.userToken {
                urlRequest.addValue(userToken, forHTTPHeaderField: "token")
            }
        }
        if let userFacebookToken = userService.userFacebookToken {
            urlRequest.addValue(userFacebookToken, forHTTPHeaderField: "Facebook-Token")
        }
        
        return urlRequest
    }
}
