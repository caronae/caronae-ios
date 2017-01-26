#import <AFNetworking/UIWebView+AFNetworking.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "CaronaeAlertController.h"
#import "WebViewController.h"

@implementation WebViewController

- (void)viewDidLoad {
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
    
    NSString *urlString;
    if (self.page == WebViewAboutPage) {
        self.title = @"Sobre";
        urlString = CaronaeAboutPageURLString;
    }
    else if (self.page == WebViewTermsOfUsePage) {
        self.title = @"Termos de Uso";
        urlString = CaronaeTermsOfUsePageURLString;
    }
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.webView loadRequest:urlRequest];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:(BOOL)animated];
    [SVProgressHUD dismiss];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD dismiss];
    
    NSString *errorAlertTitle, *errorAlertMessage;
    if (![AFNetworkReachabilityManager sharedManager].isReachable) {
        errorAlertTitle = @"Sem conexão com a internet";
        errorAlertMessage = @"Verifique sua conexão com a internet e tente novamente.";
    }
    else {
        errorAlertTitle = @"Algo deu errado.";
        errorAlertMessage = @"Não foi possível carregar a página. Por favor, tente novamente.";
    }
    
    [CaronaeAlertController presentOkAlertWithTitle:errorAlertTitle message:errorAlertMessage];
}

@end
