import Alamofire

class CaronaeAPIHTTPSessionManager: SessionManager {
    static let instance = CaronaeAPIHTTPSessionManager()

    private init() {
        super.init(configuration: .default, delegate: SessionDelegate())

        self.adapter = CaronaeRequestAdapter()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
