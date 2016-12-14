import UIKit
import WebKit

@objc
protocol CaronaeSignInDelegate: class {
    func caronaeDidSignInWithSuccess(user: String, token: String)
    func caronaeSignInFailed()
}

class CaronaeSignInViewController: UIViewController, WKNavigationDelegate {
    
    private var webView: WKWebView!
    private let url = URL(string: CaronaeIntranetURLString)
    weak var delegate: CaronaeSignInDelegate?
    
    class func presentFromViewController(_ viewController: UIViewController, delegate: CaronaeSignInDelegate) {
        let signInController = CaronaeSignInViewController()
        signInController.delegate = delegate
        
        let navigationController = UINavigationController(rootViewController: signInController)
        viewController.present(navigationController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Login Intranet UFRJ"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        
        webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self
        self.view = webView
        
        let request = URLRequest(url: self.url!)
        webView.load(request)
        
        SVProgressHUD.show()
    }
    
    func cancelButtonTapped() {
        SVProgressHUD.dismiss()
        dismiss(animated: true) {
            self.delegate?.caronaeSignInFailed()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
        
        if webView.url?.absoluteString == self.url?.absoluteString {
            let getUserCredentialsJS = "JSON.stringify({user: document.querySelector('#user').value, token: document.querySelector('.token').innerHTML})"
            webView.evaluateJavaScript(getUserCredentialsJS) { (data, error) in
                guard let resultJson = data as? String else {
                    print("Error executing JavaScript on page")
                    return
                }
                
                self.handleResult(fromJSONString: resultJson)
            }
        }
    }
    
    // TODO: Handle webView loading errors
    
    private func handleResult(fromJSONString string: String) {
        guard let jsonData = string.data(using: .utf8),
            let result = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String] else {
                print("Error reading data")
                self.delegate?.caronaeSignInFailed()
                return
        }
        
        if let user = result?["user"], let token = result?["token"] {
            dismiss(animated: true) {
                self.delegate?.caronaeDidSignInWithSuccess(user: user, token: token)
            }
        }
    }
}
