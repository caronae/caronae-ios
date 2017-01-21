import Foundation

let CaronaeErrorDomain = "br.ufrj.caronae.error"

class CaronaeError: NSError {
    private(set) var caronaeCode: Code = .unknown
    enum Code: Int {
        case unknown
        case invalidResponse
        case invalidCredentials
        case invalidUser
        case notLoggedIn
        case notLoggedInWithFacebook
    }
    
    required convenience init(code: Code, description: String) {
        let userInfo = [NSLocalizedDescriptionKey: description]
        self.init(domain: CaronaeErrorDomain, code: code.rawValue, userInfo: userInfo)
        self.caronaeCode = code
    }
    
    class var invalidCredentials: CaronaeError {
        return self.init(code: .invalidCredentials,
                         description: "As credenciais do usuário não foram aceitas pelo servidor.")
    }
    
    class var invalidResponse: CaronaeError {
        return self.init(code: .invalidResponse,
                         description: "A resposta recebida do servidor foi inválida.")
    }
    
    class var invalidUser: CaronaeError {
        return self.init(code: .invalidUser,
                         description: "O formato do usuário salvo é inválido.")
    }
    
    class var notLoggedIn: CaronaeError {
        return self.init(code: .notLoggedIn,
                         description: "O usuário não fez login.")
    }
    
    class var notLoggedInWithFacebook: CaronaeError {
        return self.init(code: .notLoggedInWithFacebook,
                         description: "O usuário não fez login com o Facebook.")
    }
}
