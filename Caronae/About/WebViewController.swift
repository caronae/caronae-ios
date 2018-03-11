import UIKit
import SVProgressHUD
import AFNetworking

class WebViewController: UIViewController, UIWebViewDelegate {

    enum WebViewPage {
        case aboutPage
        case termsOfUsePage
        case FAQPage
    }
    
    @IBOutlet weak var webView: UIWebView!
    var page: WebViewPage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.delegate = self
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
        
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        webView.loadRequest(urlRequest)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SVProgressHUD.dismiss()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        SVProgressHUD.dismiss()
        
        var errorAlertTitle: String!
        var errorAlertMessage: String!
        if !AFNetworkReachabilityManager.shared().isReachable {
            errorAlertTitle = "Sem conexão com a internet"
            errorAlertMessage = "Verifique sua conexão com a internet e tente novamente."
        } else {
            errorAlertTitle = "Algo deu errado."
            errorAlertMessage = "Não foi possível carregar a página. Por favor, tente novamente."
        }
        
        CaronaeAlertController.presentOkAlert(withTitle: errorAlertTitle, message: errorAlertMessage)
    }
}
