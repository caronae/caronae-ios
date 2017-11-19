import Foundation

enum CaronaeErrorCode: Int {
    case unknown
    case invalidResponse
    case invalidCredentials
    case invalidUser
    case invalidRide
    case notLoggedIn
    case notLoggedInWithFacebook
}

class CaronaeError: NSError {
    private(set) var caronaeCode: CaronaeErrorCode = .unknown
    
    required convenience init(code: CaronaeErrorCode, description: String) {
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
    
    class var invalidRide: CaronaeError {
        return self.init(code: .invalidRide,
                         description: "O servidor não encontrou a carona solicitada.")
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
