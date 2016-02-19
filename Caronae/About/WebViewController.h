#import <UIKit/UIKit.h>

typedef enum {
    WebViewAboutPage,
    WebViewTermsOfUsePage,
    WebViewFAQPage
} WebViewPage;

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, assign) WebViewPage page;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
