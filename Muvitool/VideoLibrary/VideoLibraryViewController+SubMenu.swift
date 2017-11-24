import UIKit
import Photos

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red Component")
        assert(green >= 0 && green <= 255, "Invalid green Component")
        assert(blue >= 0 && blue <= 255, "Invalid blue Component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex rgb: Int) {
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }
}

extension VideoLibraryViewController {
    @discardableResult
    func customActivityIndicator(_ viewContainer: UIView, startAnimate: Bool? = true) -> UIActivityIndicatorView {
        let mainContainer: UIView = UIView(frame: viewContainer.frame)
        mainContainer.center = viewContainer.center
        mainContainer.backgroundColor = UIColor(netHex: 0xFFFFFF)
        mainContainer.alpha = 0.5
        mainContainer.tag = 789456123
        mainContainer.isUserInteractionEnabled = false
        
        let viewBackgroundLoading: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        viewBackgroundLoading.center = viewContainer.center
        viewBackgroundLoading.backgroundColor = UIColor(netHex: 0x222222)
        viewBackgroundLoading.alpha = 0.5
        viewBackgroundLoading.clipsToBounds = true
        viewBackgroundLoading.layer.cornerRadius = 15
        
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
        activityIndicatorView.center = CGPoint(x: viewBackgroundLoading.frame.size.width / 2, y: viewBackgroundLoading.frame.size.height / 2)
        if startAnimate! {
            DispatchQueue.main.async {
                for subview in viewContainer.subviews {
                    subview.isUserInteractionEnabled = false
                }
            }
            viewBackgroundLoading.addSubview(activityIndicatorView)
            mainContainer.addSubview(viewBackgroundLoading)
            viewContainer.addSubview(mainContainer)
            activityIndicatorView.startAnimating()
        } else {
            DispatchQueue.main.async {
                for subview in viewContainer.subviews {
                    subview.isUserInteractionEnabled = true
                    if subview.tag == 789456123 {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
        return activityIndicatorView
    }
    
    func showSubmenu(row: Int) {
        log.info("row = \(row)")
        let vm = self.selectVideoModel(row: row)
        let absoluteFilename = "\(vm.folderPath)/\(vm.filename)"
        
        let playVideoAction = UIAlertAction(title: Strings.Play, style: .default, handler: { (alertAction: UIAlertAction) in
            self.playVideo(row: row)
        })
        
        let renameFileAction = UIAlertAction(title: Strings.Rename, style: .default, handler: { (alertAction: UIAlertAction) in
            self.present(UINavigationController(rootViewController: EditorVideoController(vm)), animated: true, completion: nil)
        })
        
        let saveToRollAction = UIAlertAction(title: Strings.SaveToRoll, style: .default, handler: { (alertAction: UIAlertAction) in
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                //self.progressIndicator.startAnimating()
                self.customActivityIndicator(self.view, startAnimate: true)
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: absoluteFilename))
                }) { saved, error in
                    var message = "", title = ""
                    if saved {
                        title = Strings.OK
                        message = Strings.VideoSuccessSaved
                    } else {
                        title = Strings.Error
                        message = Strings.VideoUnsuccessSaved
                    }
                    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let da = UIAlertAction(title: Strings.OK, style: .default, handler: nil)
                    ac.addAction(da)
                    DispatchQueue.main.async {
                        self.present(ac, animated: true, completion: {
                            self.customActivityIndicator(self.view, startAnimate: false)
                        })
                    }
                }
                
            } else {
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if (newStatus != PHAuthorizationStatus.authorized) {
                        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
                        let ac = UIAlertController(title: Strings.DeniedToRoll, message: String(format: Strings.GoToSettings, appName), preferredStyle: .alert)
                        let da = UIAlertAction(title: Strings.OK, style: .default, handler: nil)
                        ac.addAction(da)
                        self.present(ac, animated: true, completion: nil)
                    }
                })
            }
        })
        
        let extractAudioAction = UIAlertAction(title: Strings.ExtractAudio, style: .default, handler: { (alertAction: UIAlertAction) in
            self.present(UINavigationController(rootViewController: EditorSongController(vm)), animated: true, completion: nil)
        })
        
        let deleteFileAction = UIAlertAction(title: Strings.Delete, style: .default, handler: { (alertAction: UIAlertAction) in
            let ac = UIAlertController(title: Strings.AreYouSure, message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: Strings.Yes, style: .default, handler: { (alertAction: UIAlertAction) in
                self.vfmShare.delete(filename: vm.filename)
                self.reloadData()
            }))
            ac.addAction(UIAlertAction(title: Strings.No, style: .default, handler: nil))
            self.present(ac, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: Strings.Cancel, style: .default, handler: nil)
        
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(playVideoAction)
        vc.addAction(renameFileAction)
        vc.addAction(saveToRollAction)
        vc.addAction(extractAudioAction)
        vc.addAction(deleteFileAction)
        vc.addAction(cancelAction)
        vc.popoverPresentationController?.sourceView = self.view
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        vc.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)

        //optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.present(vc, animated: true, completion: {
            if (vc.view.superview?.subviews.count)! > 0 {
                vc.view.superview?.subviews[0].isUserInteractionEnabled = true
                vc.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VideoLibraryViewController.alertControllerBackgroundTapped(_:))))
            }
        })
    }
    
    @IBAction func alertControllerBackgroundTapped(_ sender: UITapGestureRecognizer) {
        self.log.info(sender)
        self.dismiss(animated: true, completion: nil)
    }
}
