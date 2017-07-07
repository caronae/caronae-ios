import Foundation

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
        
        switch resource {
        case "carona":
            guard let idString = pathComponents.popFirst(), let id = Int(idString) else {
                return nil
            }
            return .loadRide(withID: id)
        default:
            return nil
        }
    }
}
