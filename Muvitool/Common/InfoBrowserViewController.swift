import UIKit
import WebKit
import XCGLogger
import SnapKit
import XCGLogger

class InfoBrowserViewController: UIViewController {
    let log = XCGLogger.default

    var webView: WKWebView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("Info", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeAction))

        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        self.webView = WKWebView(frame: CGRect.zero, configuration: configuration)

        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top)
            $0.left.equalTo(self.view.snp.left)
            $0.right.equalTo(self.view.snp.right)
            $0.bottom.equalTo(self.view.snp.bottom)
        }
    }
    
    func loadPage(url: URL) {
        self.webView.loadFileURL(url, allowingReadAccessTo: url)
    }

    func closeAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
