import UIKit
import Eureka
import XCGLogger

class UploadingViewController: FormViewController {
    let log = XCGLogger.default
    
    var fileItemUploader: FileItemUploader!
    
    var webUploader:          WebUploader!
    var filesUploadedSection: Section!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Strings.Uploading
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(UploadingViewController.didCancelUploading(_:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress), name: NSNotification.Name(rawValue: "WebUploaderFinished"), object: nil)
        
        form +++ Section(Strings.UploadFromBrowser)
            <<< SwitchRow("uploadSwitchRowTag") { row in
                row.title = Strings.Enable
                }.onChange { row in
                    let addressLabelRow = self.form.rowBy(tag: "addressLabelRow") as! LabelRow
                    if row.value! {
                        row.title = Strings.Disable
                        addressLabelRow.title = self.webUploader.start()
                    } else {
                        row.title = Strings.Enable
                        self.webUploader.stop()
                        addressLabelRow.title = ""
                    }
                    row.updateCell()
            }
            <<< LabelRow("addressLabelRow") {
                $0.hidden = Condition.function(["uploadSwitchRowTag"], { form in
                    return !((form.rowBy(tag: "uploadSwitchRowTag") as? SwitchRow)?.value ?? false)
                })
        }
        self.filesUploadedSection = Section(Strings.FilesUploaded)
        form +++ self.filesUploadedSection
    }

    func updateProgress(_ notification: Notification) {
        if let filename = notification.userInfo?["filename"] as? String {
            self.log.info("filename = \(filename)")
            DispatchQueue.main.async {
                let tr = TextRow()
                tr.value = filename
                self.filesUploadedSection.insert(tr, at: 0)
                /*
                self.filesUploadedSection <<< TextRow() {
                    $0.value = filename
                }
                */
            }
        }
    }
    
    @IBAction func didCancelUploading(_ sender: UIBarButtonItem) {
        if self.webUploader.isRunning() {
            let ac = UIAlertController(title: Strings.AreYouSure, message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: Strings.Yes, style: .default, handler: { (alertAction: UIAlertAction) in
                self.webUploader.stop()
                self.dismiss(animated: true, completion: nil)
            }))
            ac.addAction(UIAlertAction(title: Strings.No, style: .default, handler: nil))
            self.present(ac, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
