import UIKit
import Eureka
import XCGLogger
import SwiftValidate

class EditorSongController: FormViewController {
    let log = XCGLogger.default
    
    static let CancelActionNotification = Notification.Name(rawValue: "EditorSongControllerCancelActionNotification")
    
    let coverImageRowTAG   = "coverImageRow"
    let sliderRowTAG       = "sliderRow"
    let filenameAreaRowTAG = "filenameAreaRow"
    let titleAreaRowTAG    = "titleAreaRow"
    let artistAreaRowTAG   = "artistAreaRow"
    
    var videoFileModel: VideoFileModel!
    
    var validator: ValidationIterator = ValidationIterator()    
    
    let coverSize      = CGFloat(150)
    let textViewHeight = CGFloat(80)
    
    init(_ videoFileModel: VideoFileModel) {
        super.init(style: .plain)
        self.videoFileModel = videoFileModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureValidation() {
        self.validator.register(chain:
            ValidatorChain() {
                $0.stopOnException = false
            }, forKeys: [ self.coverImageRowTAG ])
        self.validator.register(chain:
            ValidatorChain() {
                $0.stopOnException = false
        }, forKeys: [ self.sliderRowTAG ])
        self.validator.register(chain:
            ValidatorChain() {
                $0.stopOnException = true
                $0.stopOnFirstError = true
                }
                <~~ ValidatorRequired() {
                    $0.errorMessage = Strings.FilenameErrorMessage                    
                }
                <~~ ValidatorEmpty() {
                    $0.errorMessage = Strings.FilenameCannotEmpty                    
                }
            , forKeys: [ self.filenameAreaRowTAG ])
        self.validator.register(chain:
            ValidatorChain() {
                $0.stopOnException = true
                $0.stopOnFirstError = true
                }
                <~~ ValidatorRequired() {
                    $0.errorMessage = Strings.TitleErrorMessage
                }
                <~~ ValidatorEmpty() {
                    $0.errorMessage = Strings.TitleCannotEmpty
            }
            , forKeys: [ self.titleAreaRowTAG ])
        self.validator.register(chain:
            ValidatorChain() {
                $0.stopOnException = true
                $0.stopOnFirstError = true
                }
                <~~ ValidatorRequired() {
                    $0.errorMessage = Strings.PleaseEnterArtist
                }
                <~~ ValidatorEmpty() {
                    $0.errorMessage = Strings.ArtistCannotEmpty
            }
            , forKeys: [ self.artistAreaRowTAG ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditorSongController.cancelAction(_:)), name: EditorSongController.CancelActionNotification, object: nil)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(EditorSongController.cancelAction(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EditorSongController.doneAction(_:)))

        ImageRow.defaultCellUpdate = { cell, row in
            //cell.accessoryView?.layer.cornerRadius = 17
            //cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
            cell.accessoryView?.frame = CGRect(x: -100, y: 0, width: self.coverSize, height: self.coverSize)
        }
        
        form +++ Section(Strings.Cover)
            <<< ImageRow() {
                $0.tag = self.coverImageRowTAG
                $0.value = self.videoFileModel.imagePreview
                $0.cell.height = {
                    return self.coverSize + 10
                }
            }
            <<< SliderRow() {
                $0.tag = self.sliderRowTAG
                $0.value = 0
                $0.steps = UInt(self.videoFileModel.duration)
                $0.maximumValue = Float(self.videoFileModel.duration)
                }.onChange { coverImageRow in
                    if let second = coverImageRow.value {
                        let image = self.videoFileModel.image(atSecond: second)
                        let imageRow = self.form.rowBy(tag: self.coverImageRowTAG) as! ImageRow
                        imageRow.value = image
                        imageRow.updateCell()
                    }
                }
            
    
        form +++ Section(Strings.Filename)
            <<< TextAreaRow() {
                $0.tag = self.filenameAreaRowTAG
                $0.placeholder = Strings.Filename
                $0.value = self.videoFileModel.filename.deletingPathExtension()
                $0.textAreaHeight = .dynamic(initialTextViewHeight: self.textViewHeight)
            }
       
        form +++ Section(Strings.Title)
            <<< TextAreaRow() {
                $0.tag = self.titleAreaRowTAG
                $0.placeholder = Strings.Title
                $0.value = ""
                $0.textAreaHeight = .dynamic(initialTextViewHeight: self.textViewHeight)
        }
        form +++ Section(Strings.Artist)
            <<< TextAreaRow() {
                $0.tag = self.artistAreaRowTAG
                $0.placeholder = Strings.Artist
                $0.value = ""
                $0.textAreaHeight = .dynamic(initialTextViewHeight: self.textViewHeight)
        }
        
        self.configureValidation()
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        let formResults = self.form.values()
        let valid = self.validator.validate(formResults)
        if !valid {
            let errors = self.validator.getAllErrors()
            let msg    = errors.map({ (foo: String, bar: [String]) -> String in
                return bar.joined(separator: "\n")
            })
            let alert: UIAlertController = UIAlertController(title: Strings.Error, message: msg.joined(separator: "\n"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Strings.OK, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        let coverImageRow = form.rowBy(tag: self.coverImageRowTAG) as! ImageRow
        let filenameAreaRow = form.rowBy(tag: self.filenameAreaRowTAG) as! TextAreaRow
        let titleAreaRow = form.rowBy(tag: self.titleAreaRowTAG) as! TextAreaRow
        let artistAreaRow = form.rowBy(tag: self.artistAreaRowTAG) as! TextAreaRow
        
        let audioOutputFile = "\(AudioFileManager.musicFilePath)/\(filenameAreaRow.value!).m4a"
        self.log.info("audioOutputFile = \(audioOutputFile)")

        let videoInputFile = "\(self.videoFileModel.folderPath)/\(self.videoFileModel.filename)"
        let artwork = coverImageRow.cell.row.value!
        let title = titleAreaRow.cell.row.value!
        let artist = artistAreaRow.cell.row.value!
        
        if FileManager.default.fileExists(atPath: audioOutputFile) {
            let ac = UIAlertController(title: Strings.FilenameAlreadyExistsOverride, message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: Strings.Yes, style: .default, handler: { (alertAction: UIAlertAction) in
                do {
                    try FileManager.default.removeItem(atPath: audioOutputFile)
                } catch {
                    self.log.error(error)
                }
                let vc = ExtractionAudioViewController()
                let nc = UINavigationController(rootViewController: vc)
                self.present(nc, animated: true, completion: {
                    vc.start(videoInputFile, audioOutputFile, title, artist, artwork)
                })
            }))
            ac.addAction(UIAlertAction(title: Strings.No, style: .default, handler: nil))
            self.present(ac, animated: true, completion: nil)
            return
        }
        let vc = ExtractionAudioViewController()
        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true, completion: {
            vc.start(videoInputFile, audioOutputFile, title, artist, artwork)
        })
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
