import UIKit
import WebKit

@objc
protocol CaronaeSignInDelegate: class {
    func caronaeDidSignInWithSuccess(user: String, token: String)
    func caronaeSignInFailed()
}

class SignInViewController: UIViewController {

    fileprivate let url = URL(string: CaronaeIntranetURLString)
    weak var delegate: CaronaeSignInDelegate?
    
    class func presentFromViewController(_ viewController: UIViewController, delegate: CaronaeSignInDelegate) {
        let signInController = SignInViewController()
        signInController.delegate = delegate
        
        let navigationController = UINavigationController(rootViewController: signInController)
        viewController.present(navigationController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Login Intranet UFRJ"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSignIn))
        
        let webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self
        self.view = webView
        
        let request = URLRequest(url: self.url!)
        webView.load(request)
        
        SVProgressHUD.show()
    }
    
    func cancelSignIn() {
        SVProgressHUD.dismiss()
        dismiss(animated: true) {
            self.delegate?.caronaeSignInFailed()
        }
    }
    
    fileprivate func handleResult(fromJSONString string: String) {
        guard let jsonData = string.data(using: .utf8),
            let result = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String] else {
                print("Error reading data")
                return
        }
        
        if let user = result?["user"], let token = result?["token"] {
            dismiss(animated: true) {
                self.delegate?.caronaeDidSignInWithSuccess(user: user, token: token)
            }
        }
    }
}


extension SignInViewController: WKNavigationDelegate {
    
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
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        SVProgressHUD.dismiss()
        CaronaeAlertController.presentOkAlert(withTitle: "Erro de conexão", message: "Não foi possível conectar com a Intranet UFRJ. Verifique sua conexão com a internet e tente novamente.") {
            self.cancelSignIn()
        }
    }
}
