import UIKit
import AVFoundation
import XCGLogger

class VideoFileModel: FileItemUpload {
    let log = XCGLogger.default
    
    var generator: AVAssetImageGenerator!
    var folderPath: String = ""
    var duration: Double = 0
    var imagePreview: UIImage = UIImage(named: "no_video")!
    
    init(withFilename filename: String, inFolderPath folderPath: String) {
        super.init()
        
        self.filename = filename
        self.folderPath = folderPath
        let filePath = "\(self.folderPath)/\(self.filename)"
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            
            self.filesize = attr[FileAttributeKey.size] as! Int64
            self.datetime = attr[FileAttributeKey.creationDate] as! Date
            
            let url = URL(fileURLWithPath: filePath)
            let asset = AVURLAsset(url: url)
            
            self.duration = asset.duration.seconds
            
            self.generator = AVAssetImageGenerator(asset: asset)
            self.generator.appliesPreferredTrackTransform = true
            let timestamp = CMTime(seconds: asset.duration.seconds / 10, preferredTimescale: 60)
            let imageRef = try self.generator.copyCGImage(at: timestamp, actualTime: nil)
            self.imagePreview = UIImage(cgImage: imageRef)
        } catch {
            self.log.error(error)
        }
    }
    
    func image(atSecond second: Float) -> UIImage {
        do {
            let timestamp = CMTime(seconds: Double(second), preferredTimescale: 60)
            let imageRef = try self.generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return UIImage(named: "no_video")!
        }
    }
}
