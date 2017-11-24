import UIKit
import XCGLogger

class FileItemManager: NSObject {
    let log = XCGLogger.default
    static let log = XCGLogger.default
    
    open static let baseFolderPath: String = {
        let folder = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/Music2"
        log.info("folder = \(folder)")
        let fm = FileManager.default
        if fm.fileExists(atPath: folder) == false {
            do {
                try fm.createDirectory(atPath: folder, withIntermediateDirectories: false, attributes: nil)
            } catch {
                log.error(error)
            }
        }
        return folder
    }()
    
    static let shared: FileItemManager = {
        let instance = FileItemManager()
        return instance
    }()
    
    func insert(filename: String) {
        self.log.info("filename = \(filename)")
        let fm = FileManager.default
        let atPath = "\(FileItemManager.baseFolderPath)/\(filename)"
        let uuid =  UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        let toPath = "\(AudioFileManager.musicFilePath)/\(uuid)"
        do {
            try fm.moveItem(atPath: atPath, toPath: toPath)
            self.log.info("atPath = \(atPath)")
            self.log.info("toPath = \(toPath)")
            
            let attr = try fm.attributesOfItem(atPath: toPath)
        
            let filesize = attr[FileAttributeKey.size] as! Int64
            let datetime = attr[FileAttributeKey.creationDate] as! Date
        
            let fileItem = FileItem(id: 0,
                                filename: filename.deletingPathExtension(),
                                pathExtension: filename.getPathExtension(),
                                uuid:          uuid,
                                filesize:      filesize,
                                datetime:      datetime)
            let id = FileItemDataHelper.insert(fileItem)
            self.log.info("FileItemDataHelper.insert id = \(id)")
        } catch {
            self.log.error(error)
        }
    }
    
    func rename(fileItemId: Int64, withFilename filename: String) -> Bool {
        self.log.info("fileItemId = \(fileItemId), filename = \(filename)")
        if var fileItem = FileItemDataHelper.find(withId: fileItemId) {
            fileItem.filename = filename
            return ( FileItemDataHelper.update(fileItem) > 0 )
        }
        return false
    }
}
