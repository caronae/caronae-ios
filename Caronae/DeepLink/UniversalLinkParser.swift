import Foundation

class UniversalLinkParser {
    static let shared = UniversalLinkParser()
    private init() { }
    
    func parseLink(_ url: URL) -> DeeplinkType? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
            return nil
        }
        
        var pathComponents = components.path.components(separatedBy: "/")

        // The first component is empty
        pathComponents.removeFirst()
        
        switch host {
        case "carona":
            guard let idString = pathComponents.first, let id = Int(idString) else {
                return nil
            }
            return .loadRide(withID: id)
        default:
            return nil
        }
    }
}
