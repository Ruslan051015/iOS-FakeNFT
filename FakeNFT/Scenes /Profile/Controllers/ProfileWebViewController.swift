import UIKit
import WebKit

class ProfileWebViewController: UIViewController, WKUIDelegate {
  // MARK: - Properties:
  var userSite: String = "" {
    didSet {
      guard let url = URL(string: userSite) else { return }
      let request = URLRequest(url: url)
      webView.load(request)
    }
  }
  
  private lazy var webView: WKWebView = {
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    webView.allowsBackForwardNavigationGestures =  true
    
    return webView
  }()
  
  // MARK: - LifeCycle:
  override func viewDidLoad() {
    super.viewDidLoad()
    
    webView.uiDelegate = self
    view = webView
  }
}
