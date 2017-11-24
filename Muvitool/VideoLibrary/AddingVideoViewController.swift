import UIKit
import XCGLogger
import SnapKit
import Photos

class AddingVideoViewController: UIViewController, UINavigationControllerDelegate {
    let log = XCGLogger.default
    
    let vfmShare = VideoFileManager.shared
    
    var uploadFromComputerButton: UIButton!
    var loadFromRollButton:       UIButton!
    let imagePickerController = UIImagePickerController()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = Strings.AddingVideo
        self.view.backgroundColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AddingVideoViewController.cancelAction(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddingVideoViewController.doneAction(_:)))
        
        self.uploadFromComputerButton = UIButton(type: .system)
        self.uploadFromComputerButton.backgroundColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1.0)
        self.uploadFromComputerButton.layer.cornerRadius = 20
        self.uploadFromComputerButton.layer.borderWidth = 1
        self.uploadFromComputerButton.layer.borderColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1.0).cgColor
        self.uploadFromComputerButton.setTitleColor(UIColor.white, for: .normal)
        self.uploadFromComputerButton.titleLabel?.font = UIFont(name: "Verdana", size: 20)
        self.uploadFromComputerButton.setTitle(Strings.FromYourComputer, for: .normal)
        self.uploadFromComputerButton.addTarget(self, action: #selector(AddingVideoViewController.uploadFromComputer(_:)), for: .touchUpInside)
        self.view.addSubview(self.uploadFromComputerButton)
        self.uploadFromComputerButton.snp.makeConstraints {
            $0.width.equalTo(250)
            $0.height.equalTo(70)
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.bottom.equalTo(self.view.snp.centerY).offset(-10)
        }
        
        self.loadFromRollButton = UIButton(type: .system)
        self.loadFromRollButton.backgroundColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1.0)
        self.loadFromRollButton.layer.cornerRadius = 20
        self.loadFromRollButton.layer.borderWidth = 1
        self.loadFromRollButton.layer.borderColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1.0).cgColor
        self.loadFromRollButton.setTitleColor(UIColor.white, for: .normal)
        self.loadFromRollButton.titleLabel?.font = UIFont(name: "Verdana", size: 20)
        self.loadFromRollButton.setTitle(Strings.LoadFromRoll, for: .normal)
        self.loadFromRollButton.addTarget(self, action: #selector(AddingVideoViewController.loadFromRoll(_:)), for: .touchUpInside)
        self.view.addSubview(self.loadFromRollButton)
        self.loadFromRollButton.snp.makeConstraints {
            $0.width.equalTo(250)
            $0.height.equalTo(70)
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.top.equalTo(self.view.snp.centerY).offset(10)
        }
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadFromComputer(_ sender: UIButton) {
        let vc = UploadingViewController()
        vc.webUploader = WebUploader(
            uploadDirectory: VideoFileManager.baseFolderPath,
            multimediaArray: VideoFileManager.shared.data,
            delegate: {
                class VideoWebUploaderDelegate: WebUploaderDelegate {
                    func reloadData() -> Array<FileItemUpload> {
                        VideoFileManager.shared.reloadData()
                        return VideoFileManager.shared.data
                    }
                }
                return VideoWebUploaderDelegate()
        }()
        )
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }

    @IBAction func loadFromRoll(_ sender: UIButton) {
        log.info("\(sender)")
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
}

extension AddingVideoViewController: UIImagePickerControllerDelegate {    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let referenceURL = info["UIImagePickerControllerReferenceURL"] {
            if let assetURL = NSURL(string: String(describing: referenceURL)) {
                let assets = PHAsset.fetchAssets(withALAssetURLs: [assetURL as URL], options: nil)
                if let asset : PHAsset = assets.firstObject {
                    let manager = PHImageManager.default()
                    manager.requestAVAsset(forVideo: asset, options: nil, resultHandler: { (asset, avAudioMix, dict) -> Void in
                        self.log.info(dict)
                        if let avURLAsset = asset as? AVURLAsset {
                            let filename = avURLAsset.url.lastPathComponent
                            let destURL = URL(fileURLWithPath: filename, relativeTo: avURLAsset.url.deletingLastPathComponent())
                            self.vfmShare.copy(url: avURLAsset.url)
                            DispatchQueue.main.async {
                                self.imagePickerController.dismiss(animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
        }
    }
    //
}
