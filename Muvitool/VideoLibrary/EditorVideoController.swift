import UIKit
import Eureka
import XCGLogger

class EditorVideoController: FormViewController {
    let log = XCGLogger.default
    
    var videoFileModel: VideoFileModel!
    let coverSize      = CGFloat(150)

    init(_ videoFileModel: VideoFileModel) {
        super.init(style: .plain)
        self.videoFileModel = videoFileModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(EditorSongController.cancelAction(_:)))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EditorSongController.doneAction(_:)))
        
        ImageRow.defaultCellUpdate = { cell, row in
            
            cell.accessoryView?.frame = CGRect(x: -100, y: 0, width: self.coverSize, height: self.coverSize)
        }
        
        form +++ Section(Strings.Cover)
            <<< ImageRow() {
                $0.tag = "coverImageRow"
                $0.value = self.videoFileModel.imagePreview
                $0.cell.height = {
                    return self.coverSize + 10
                }
            }

        form +++ Section(Strings.Filename)
            <<< TextAreaRow() {
                $0.tag = "filenameAreaRow"
                $0.placeholder = Strings.Filename
                $0.value = self.videoFileModel.filename.deletingPathExtension()
            }
    }

    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        let filenameAreaRow = form.rowBy(tag: "filenameAreaRow") as! TextAreaRow
        
        if filenameAreaRow.value! == "" {	
            let vc = UIAlertController(title: Strings.FilenameCannotEmpty, message: "", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: Strings.No, style: .default, handler: nil)
            vc.addAction(closeAction)
            self.present(vc, animated: true, completion: nil)
            return
        }

        let pathExtension = self.videoFileModel.filename.getPathExtension()
        let videoFile = "\(VideoFileManager.baseFolderPath)/\(filenameAreaRow.value!).\(pathExtension)"
        self.log.info("videoFile = \(videoFile)")

        if FileManager.default.fileExists(atPath: videoFile) {
            let ac = UIAlertController(title: Strings.FilenameAlreadyExistsOverride, message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: Strings.Yes, style: .default, handler: { (alertAction: UIAlertAction) in
                VideoFileManager.shared.rename(self.videoFileModel, filenameAreaRow.value!)
                self.dismiss(animated: true, completion: nil)
            }))
            ac.addAction(UIAlertAction(title: Strings.No, style: .default, handler: nil))
            self.present(ac, animated: true, completion: nil)
            return
        }
        VideoFileManager.shared.rename(self.videoFileModel, filenameAreaRow.value!)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
