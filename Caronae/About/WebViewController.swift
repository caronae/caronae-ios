import UIKit
import WebKit
import SVProgressHUD
import Alamofire

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    enum WebViewPage {
        case aboutPage
        case termsOfUsePage
        case FAQPage
    }
    
    var webView: WKWebView!
    var page: WebViewPage?
    var urlRequest: URLRequest!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.scrollView.delegate = self
        webView.scrollView.bounces = false
        
        var urlString: String!
        switch page! {
        case .aboutPage:
            title = "Sobre"
            urlString = CaronaeURLString.aboutPage
        case .termsOfUsePage:
            title = "Termos de Uso"
            urlString = CaronaeURLString.termsOfUsePage
        case .FAQPage:
            title = "FAQ"
            urlString = CaronaeURLString.FAQPage
        }
        
        urlRequest = URLRequest(url: URL(string: urlString)!)
        webView.load(urlRequest)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        SVProgressHUD.show()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        SVProgressHUD.dismiss()
        
        var errorAlertTitle: String!
        var errorAlertMessage: String!
        if let reachabilityManager = NetworkReachabilityManager(),
            !reachabilityManager.isReachable {
            errorAlertTitle = "Sem conexão com a internet"
            errorAlertMessage = "Verifique sua conexão com a internet e tente novamente."
        } else {
            errorAlertTitle = "Algo deu errado."
            errorAlertMessage = "Não foi possível carregar a página. Por favor, tente novamente."
        }
        
        CaronaeAlertController.presentOkAlert(withTitle: errorAlertTitle, message: errorAlertMessage)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "RefreshIcon"), style: .plain, target: self, action: #selector(didTapRefreshButton))
    }
    
    @objc func didTapRefreshButton() {
        webView.load(urlRequest)
        navigationItem.rightBarButtonItem = nil
    }
}

// workaround to disable zoom on WKWebView
extension WebViewController: UIScrollViewDelegate {
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
