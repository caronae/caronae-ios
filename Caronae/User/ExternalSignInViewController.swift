import UIKit
import WebKit
import SVProgressHUD

protocol ExternalSignInDelegate: class {
    func externalSignInWasSuccessful(user: String, token: String)
    func externalSignInFailed()
}

class ExternalSignInViewController: UIViewController {
    fileprivate let url = URL(string: CaronaeIntranetURLString)
    weak var delegate: ExternalSignInDelegate?
    
    class func presentFromViewController(_ viewController: UIViewController, delegate: ExternalSignInDelegate) {
        let signInController = ExternalSignInViewController()
        signInController.delegate = delegate
        
        let navigationController = UINavigationController(rootViewController: signInController)
        viewController.present(navigationController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Intranet UFRJ"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSignIn))
        
        let webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self

        let request = URLRequest(url: self.url!)
        webView.load(request)
        
        view = webView
        SVProgressHUD.show()
    }
    
    func cancelSignIn() {
        SVProgressHUD.dismiss()
        dismiss(animated: true)
    }
    
    fileprivate func handleResult(fromJSONString string: String) {
        guard let jsonData = string.data(using: .utf8),
            let result = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String] else {
                print("Error reading data")
                delegate?.externalSignInFailed()
                return
        }
        
        if let user = result?["user"], let token = result?["token"] {
            dismiss(animated: true) {
                self.delegate?.externalSignInWasSuccessful(user: user, token: token)
            }
        }
    }
}


extension ExternalSignInViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
        if webView.url?.absoluteString == self.url?.absoluteString {
            webView.evaluateJavaScript("getCredentialsJSON()") { (data, error) in
                guard let resultJson = data as? String else {
                    print("Error executing JavaScript on page")
                    self.delegate?.externalSignInFailed()
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
