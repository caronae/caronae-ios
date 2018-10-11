class UniversalLinkParser {
    static let shared = UniversalLinkParser()
    private init() { }
    
    func parseLink(_ url: URL) -> DeeplinkType? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        var pathComponents = components.path.components(separatedBy: "/").dropFirst()
        guard let resource = pathComponents.popFirst() else {
            return nil
        }
        
        return handleLink(resource: resource, pathComponents: pathComponents)
    }
    
    func parseDeeplink(_ url: URL) -> DeeplinkType? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let resource = components.host else {
                return nil
        }
        
        let pathComponents = components.path.components(separatedBy: "/").dropFirst()
        return handleLink(resource: resource, pathComponents: pathComponents, queryItems: components.queryItems)
    }
    
    func handleLink(resource: String, pathComponents: ArraySlice<String>, queryItems: [URLQueryItem]? = nil) -> DeeplinkType? {
        switch resource {
        case "carona":
            guard let idString = pathComponents.first, let id = Int(idString) else {
                return nil
            }
            return .loadRide(withID: id)
        case "login":
            guard let id = getQueryParameter(queryItems: queryItems, param: "id"),
                let token = getQueryParameter(queryItems: queryItems, param: "token") else {
                return nil
            }
            return .login(withID: id, token: token)
        default:
            return nil
        }
    }
    
    private func getQueryParameter(queryItems: [URLQueryItem]?, param: String) -> String? {
        return queryItems?.first(where: { $0.name == param })?.value
    }
}
