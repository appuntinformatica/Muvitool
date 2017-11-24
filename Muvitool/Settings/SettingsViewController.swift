import UIKit
import Eureka
import XCGLogger
import SwiftyUserDefaults

class SettingsViewController: FormViewController {
    let log = XCGLogger.default
    
    var fileItemUploader: FileItemUploader!

    var webUploader:          WebUploader!
    var filesUploadedSection: Section!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = Strings.Settings
        
        form +++ Section(Strings.Informations)
            <<< LabelRow() {
                    $0.title = String(format: Strings.AppVersion, "\(Bundle.main.releaseVersionNumber)")
                    $0.cell.textLabel?.textAlignment = .center
                }
            <<< LabelRow() {
                    $0.cell.textLabel?.textAlignment = .center
                    $0.title = String(format: Strings.MusicUsedSpace, "\(AudioFileManager.shared.findSize())")
                }
            <<< LabelRow() {
                $0.cell.textLabel?.textAlignment = .center
                $0.title = String(format: Strings.VideoUsedSpace, "\(VideoFileManager.shared.findSize())")
            }
            <<< ButtonRow(Strings.ThirdPartySoftware) {
                    $0.title = $0.tag
                }.onCellSelection { row in
                    let vc = InfoBrowserViewController()
                    super.present(UINavigationController(rootViewController: vc), animated: true, completion: {
                        let url = URL(fileURLWithPath: "\(Bundle.main.bundlePath)/ThirdPartySoftware.html")
                        vc.loadPage(url: url)
                    })
                }
            <<< ButtonRow(Strings.RatingApp) {
                $0.title = $0.tag
                }.onCellSelection { _, _ in
                    self.rateApp(appId: Bundle.main.bundleIdentifier!, completion: { success in
                        self.log.info("success = \(success)")
                    })
                }
            <<< ButtonRow(Strings.ShareFacebookPage) {
                $0.title = $0.tag
                }.onCellSelection { _, _ in
                    let vc = FacebookActivityViewController(sharingItems: ["https://www.facebook.com/muvitool"])
                    vc.completionWithItemsHandler = { activity, success, items, error in
                        if !success {
                            self.log.info("cancelled")
                        } else if activity == UIActivityType.postToFacebook {
                            self.log.info("facebook")
                        }
                    }
                    vc.popoverPresentationController?.sourceView = self.view
                    vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                    vc.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    self.present(vc, animated: true, completion: nil)
                }        
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        self.log.info("appId = \(appId)")
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}
