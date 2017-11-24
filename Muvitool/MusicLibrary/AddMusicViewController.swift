import UIKit
import XCGLogger
import SnapKit

class AddMusicViewController: UIViewController {
    
    var uploadFromComputerButton: UIButton!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Strings.AddMusic
        self.view.backgroundColor = UIColor.white

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AddMusicViewController.cancelAction(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddMusicViewController.doneAction(_:)))

        self.uploadFromComputerButton = UIButton(type: .system)
        self.uploadFromComputerButton.backgroundColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1.0)
        self.uploadFromComputerButton.layer.cornerRadius = 20
        self.uploadFromComputerButton.layer.borderWidth = 1
        self.uploadFromComputerButton.layer.borderColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1.0).cgColor
        self.uploadFromComputerButton.setTitleColor(UIColor.white, for: .normal)
        self.uploadFromComputerButton.titleLabel?.font = UIFont(name: "Verdana", size: 20)
        self.uploadFromComputerButton.setTitle(Strings.FromYourComputer, for: .normal)
        self.uploadFromComputerButton.addTarget(self, action: #selector(self.uploadFromComputerTouchUpInside(_:)), for: .touchUpInside)
        self.view.addSubview(self.uploadFromComputerButton)
        self.uploadFromComputerButton.snp.makeConstraints {
            $0.width.equalTo(250)
            $0.height.equalTo(70)
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.centerY.equalTo(self.view.snp.centerY)
        }
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func uploadFromComputerTouchUpInside(_ sender: UIButton) {
        let vc = UploadingViewController()
        vc.webUploader = WebUploader(
            uploadDirectory: AudioFileManager.musicFilePath,
            multimediaArray: AudioFileManager.shared.data,
            delegate: {
                class AudioWebUploaderDelegate: WebUploaderDelegate {
                    func reloadData() -> Array<FileItemUpload> {
                        AudioFileManager.shared.reloadData()
                        return AudioFileManager.shared.data
                    }
                }
                return AudioWebUploaderDelegate()
            }()
        )
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}
