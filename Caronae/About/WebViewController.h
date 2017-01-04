@import UIKit;

typedef enum {
    WebViewAboutPage,
    WebViewTermsOfUsePage
} WebViewPage;

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, assign) WebViewPage page;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
