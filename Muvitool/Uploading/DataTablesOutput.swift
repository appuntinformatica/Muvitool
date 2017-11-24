import UIKit

class FileItemUpload {
    private let df = DateFormatter()
    
    var filename:   String = ""
    var filesize:   Int64  = 0
    var datetime:   Date   = Date()
    
    func makeDictionary() -> [String: Any] {
        var e = Dictionary<String, Any>()
        e.updateValue(self.filename, forKey: "filename")
        
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [ .useBytes, .useKB, .useMB, .useGB ]
        byteCountFormatter.countStyle = .file
        let fz = byteCountFormatter.string(fromByteCount: self.filesize)
        e.updateValue(fz, forKey: "filesize")
        
        df.dateFormat = "dd/MM/yyyy HH:mm:ss"
        e.updateValue(df.string(from: self.datetime), forKey: "datetime")
        e.updateValue(self.filename, forKey: "actions")
        return e
    }
}

class DataTablesOutput {
    
    var draw: Int = 0
    var recordsTotal: Int = 0
    var recordsFiltered: Int = 0
    var data = Array<FileItemUpload>()
    var error: String = ""
    
    init() {
        data = Array()
    }
    
    func makeDictionary() -> Dictionary<String, Any> {
        var dic = Dictionary<String, Any>()
        dic.updateValue(self.draw, forKey: "draw")
        dic.updateValue(self.recordsTotal, forKey: "recordsTotal")
        dic.updateValue(self.recordsFiltered, forKey: "recordsFiltered")
        dic.updateValue(self.error, forKey: "error")
        var dataDic = Array<Dictionary<String, Any>>()
        for item in self.data {
            dataDic.append(item.makeDictionary())
        }
        dic.updateValue(dataDic, forKey: "data")
        
        return dic
    }
}
