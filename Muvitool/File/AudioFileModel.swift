import UIKit
import AVKit
import AVFoundation
import XCGLogger
import AudioToolbox


class AudioFileModel: FileItemUpload {
    let log = XCGLogger.default
    
    private let df = DateFormatter()
    
    var playerItem:   AVPlayerItem!
    
    var folderPath: String = ""
    var fileURL:    URL!
    
    var artwork:    UIImage = UIImage(named: "music")!
    var artist:     String = ""
    var title:      String = ""
    
    init(withFilename filename: String, inFolderPath folderPath: String) {
        super.init()
        self.filename = filename
        self.folderPath = folderPath
        let filePath = "\(self.folderPath)/\(self.filename)"
        self.log.info("filePath = \(filePath)")
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            
            self.filesize = attr[FileAttributeKey.size] as! Int64
            self.datetime = attr[FileAttributeKey.creationDate] as! Date
            
            self.fileURL = URL(fileURLWithPath: filePath)
            self.playerItem = AVPlayerItem(url: self.fileURL)
            
            for item in self.playerItem.asset.metadata {
                self.log.info("item = \(item)")
                guard let key = item.commonKey, let value = item.value else {
                    continue
                }
            
                switch key {
                case "title" : self.title = value as! String
                    break
                case "artist": self.artist = value as! String
                    break
                case "artwork":
                    if let data = value as? Data, let artwork = UIImage(data: data) {
                        self.artwork = artwork
                    }
                    break
                default:
                    continue
                }
            }
        } catch {
            log.error(error)
        }
    }    
}
