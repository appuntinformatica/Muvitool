import UIKit
import XCGLogger

class AudioFileManager: NSObject {
    let log = XCGLogger.default
    static let log = XCGLogger.default
    
    open static let musicFilePath: String = {
        let folder = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/Music"
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
    
    static let shared: AudioFileManager = {
        let instance = AudioFileManager()
        return instance
    }()
    
    var data = Array<AudioFileModel>()
    
    override init() {
        super.init()
        
        self.reloadData()
    }
    
    func findSize() -> String {
        var folderSize = 0
        FileManager.default.enumerator(at: URL(fileURLWithPath: AudioFileManager.musicFilePath), includingPropertiesForKeys: [.fileSizeKey], options: [])?.forEach {
            folderSize += (try? ($0 as? URL)?.resourceValues(forKeys: [.fileSizeKey]))??.fileSize ?? 0
        }
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [ .useBytes, .useKB, .useMB, .useGB ]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: Int64(folderSize))
    }
    
    func reloadData() {
        let fm = FileManager.default
        let url = URL(fileURLWithPath: AudioFileManager.musicFilePath)
        
        let optionMask : FileManager.DirectoryEnumerationOptions = [ .skipsHiddenFiles ]
        let keys = [ URLResourceKey.isRegularFileKey, URLResourceKey.creationDateKey, URLResourceKey.nameKey, URLResourceKey.fileSizeKey ]
        let files = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys : keys, options: optionMask )
        self.data.removeAll()
        files?.forEach {
            let item = AudioFileModel(withFilename: $0.lastPathComponent, inFolderPath: AudioFileManager.musicFilePath)
            self.data.append(item)
        }
    }

    func delete(_ item: AudioFileModel) {
        let fm = FileManager.default
        do {
            try fm.removeItem(at: item.fileURL)
            PlaylistItemDataHelper.delete(byFilename: item.filename)
            self.reloadData()
        } catch {
            self.log.error("\(error)")
        }
    }
    
    func exists(_ filename: String) -> Bool {
        let fm = FileManager.default
        return fm.fileExists(atPath: "\(AudioFileManager.musicFilePath)/\(filename)")
    }
}
