import Alamofire

class CaronaeRequestAdapter: RequestAdapter {
    private let baseURL = URL(string: CaronaeAPIBaseURLString)!
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.url = URL(string: urlRequest.url!.absoluteString, relativeTo: baseURL)
        
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
