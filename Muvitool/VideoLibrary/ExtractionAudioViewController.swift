import UIKit
import AVFoundation
import SnapKit
import XCGLogger

class ExtractionAudioViewController: UIViewController {
    let log = XCGLogger.default

    var exportSession:   AVAssetExportSession!
    var filenameLabel:   UILabel!
    var statusLabel:     UILabel!
    var progressView:    UIProgressView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ExtractionAudioViewController.cancelAction(_:)))

        self.view.backgroundColor = UIColor.white
        
        self.filenameLabel = UILabel()
        self.filenameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.filenameLabel.textAlignment = .center
        self.filenameLabel.text = Strings.Filename
        self.view.addSubview(self.filenameLabel)
        self.filenameLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top).offset(80)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
        }
         
        self.statusLabel = UILabel()
        self.statusLabel.textAlignment = .center
        self.statusLabel.text = Strings.ExtrationAudioInProgress
        self.view.addSubview(self.statusLabel)
        self.statusLabel.snp.makeConstraints {
            $0.top.equalTo(self.filenameLabel.snp.bottom).offset(5)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
        }

        self.progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 3))
        self.progressView.tintColor = UIColor.blue
        self.view.addSubview(self.progressView)
        self.progressView.snp.makeConstraints {
            $0.top.equalTo(self.statusLabel.snp.bottom).offset(5)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
            $0.height.equalTo(3)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func start(_ videoInputFile: String, _ audioOutputFile: String, _ title: String, _ artist: String, _ artwork: UIImage) {
        // http://stackoverflow.com/questions/27590510/xcode-how-to-convert-mp4-file-to-audio-file
        // http://stackoverflow.com/questions/20776026/ios-video-to-audio-file-conversion
        
        let inputURL = URL(fileURLWithPath: videoInputFile)
        self.log.info("inputURL = \(inputURL)")
        
        let outputURL = URL(fileURLWithPath: audioOutputFile)
        self.log.info("outputURL = \(outputURL)")

        let newAudioAsset = AVMutableComposition()
        let dstCompositionTrack = newAudioAsset.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let srcAsset = AVURLAsset(url: inputURL)
        if let srcTrack = srcAsset.tracks(withMediaType: AVMediaTypeAudio).first {
            let timeRange = srcTrack.timeRange
            do {
                try dstCompositionTrack.insertTimeRange(timeRange, of: srcTrack, at: kCMTimeZero)
                self.exportSession = AVAssetExportSession(asset: newAudioAsset, presetName: AVAssetExportPresetPassthrough)
                if self.exportSession != nil {
                    self.log.info("supportedFileTypes = \(exportSession.supportedFileTypes)")
                    exportSession.outputFileType = AVFileTypeAppleM4A
                    
                    var metadataItems = [AVMetadataItem]()
                    
                    let artworkItem = AVMutableMetadataItem()
                    artworkItem.keySpace = AVMetadataKeySpaceiTunes
                    artworkItem.key = AVMetadataiTunesMetadataKeyCoverArt as NSCopying & NSObjectProtocol
                    artworkItem.value = UIImagePNGRepresentation(artwork)! as NSCopying & NSObjectProtocol
                    metadataItems.append(artworkItem)
                    
                    let artistTag = AVMutableMetadataItem()
                    artistTag.keySpace = AVMetadataKeySpaceiTunes
                    artistTag.key = AVMetadataiTunesMetadataKeyArtist as NSCopying & NSObjectProtocol
                    artistTag.value = "\(artist)" as NSCopying & NSObjectProtocol
                    metadataItems.append(artistTag)
                    
                    let titleTag = AVMutableMetadataItem()
                    titleTag.keySpace = AVMetadataKeySpaceiTunes
                    titleTag.key = AVMetadataiTunesMetadataKeySongName as NSCopying & NSObjectProtocol
                    titleTag.value = "\(title)" as NSCopying & NSObjectProtocol
                    metadataItems.append(titleTag)
                    
                    exportSession.metadata = metadataItems
                    
                    exportSession.outputURL = outputURL
                    exportSession.exportAsynchronously(completionHandler: {
                        DispatchQueue.main.async {
                            self.progressView.progress = self.exportSession.progress
                            let perc = Int(100 * self.exportSession.progress)
                            switch self.exportSession.status {
                            case .completed:
                                self.statusLabel.text = Strings.SuccessExtractingAudio
                                AudioFileManager.shared.reloadData()
                                /*
                                let audioItems = [ outputURL ]
                                let activity = UIActivity()
                                // https://www.raywenderlich.com/133825/uiactivityviewcontroller-tutorial
                                let activityViewController = UIActivityViewController(activityItems: audioItems, applicationActivities: nil)
                                activityViewController.popoverPresentationController?.sourceView = self.view
                                self.present(activityViewController, animated: true, completion: nil)
                                */
                                self.dismiss(animated: true, completion: {
                                    NotificationCenter.default.post(name: EditorSongController.CancelActionNotification, object: nil)
                                })                                
                                break
                            case .cancelled:
                                self.statusLabel.text = Strings.CancelledExtractingAudio
                                break
                            case .failed:
                                self.statusLabel.text = Strings.FailedExtractingAudio
                                break
                            case .unknown:
                                self.statusLabel.text = Strings.UnknownErrorDuringExtractingAudio
                                break
                            case .waiting:
                                self.statusLabel.text = String(format: Strings.WaitingExtractingAudio, "\(perc)")                                    
                                break
                            default:
                                self.statusLabel.text = "..."
                                break
                            }
                            if self.exportSession.status != .completed {
                                self.log.warning(self.exportSession.error)
                            }
                        }
                    })
                }
            } catch {
                self.log.error(error)
            }
        } else {
            self.statusLabel.text = Strings.UnableExtractingAudio
        }
    }
    
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.log.info(sender)
        if self.exportSession != nil {
            self.exportSession.cancelExport()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
