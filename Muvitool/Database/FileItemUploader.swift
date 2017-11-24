import UIKit
import GCDWebServer
import XCGLogger

class FileItemGCDWebServerConnection: GCDWebServerConnection {
    override func processRequest(_ request: GCDWebServerRequest!, completion: GCDWebServerCompletionBlock!) {
        if let multipartRequest = request as? GCDWebServerMultiPartFormRequest {
            if let multipartFile = multipartRequest.files.first as? GCDWebServerMultiPartFile {
                var userInfo = [ AnyHashable: Any ]()
                userInfo["filename"] = multipartFile.fileName
                FileItemManager.shared.insert(filename: multipartFile.fileName)
                NotificationCenter.default.post(name: FileItemUploader.NofiticationFinished, object: self, userInfo: userInfo)
            }
        }
        super.processRequest(request, completion: completion)
    }
}

class FileItemUploader: NSObject {
    let log = XCGLogger.default
    
    static let NofiticationFinished = NSNotification.Name(rawValue: "FileItemUploaderNofiticationFinished")
    
    private var webUploader: GCDWebUploader!
    
    func start() -> String {
        self.webUploader = GCDWebUploader(uploadDirectory: FileItemManager.baseFolderPath)
        
        let directoryPath = "\(Bundle.main.bundlePath)/Website"
        self.log.info("directoryPath = \(directoryPath)")
        
        self.webUploader.addGETHandler(forBasePath: "/", directoryPath: directoryPath, indexFilename: "index.html", cacheAge: 0, allowRangeRequests: true)
        
        self.webUploader.addHandler(forMethod: "GET", path: "/list", request: GCDWebServerRequest.self, processBlock: { (request: GCDWebServerRequest?) -> GCDWebServerResponse? in
            var start = 0, length = 0, draw = 0, colOrderIndex = 0
            var searchValue = "", colOrderDir = ""
            
            request?.query?.forEach({ e in
                self.log.info(e)
                if e.key.description == "draw" {
                    draw = Int(e.value as! String)!
                } else if e.key.description == "start" {
                    start = Int(e.value as! String)!
                } else if e.key.description == "length" {
                    length = Int(e.value as! String)!
                } else if e.key.description == "search.value" {
                    searchValue = e.value as! String
                } else if e.key.description == "order[0].column" {
                    colOrderIndex = Int(e.value as! String)!
                } else if e.key.description == "order[0].dir" {
                    colOrderDir = e.value as! String
                }
            })
            self.log.info("\n draw = \(draw)\n start = \(start)\n length = \(length)\n search.value = \(searchValue)\n colOrderIndex = \(colOrderIndex)\n colOrderDir = \(colOrderDir)")
            let end = start + length
                                    
            let recordsTotal = FileItemDataHelper.getRecordsTotal()
            
            var orderByFileItem: OrderByFileItem!
            switch (colOrderIndex) {
            case 0:
                orderByFileItem = .filename
            break
            case 1:
                orderByFileItem = .filesize
                break
            case 2:
                orderByFileItem = .datetime
            break
            default:
                break
            }
            var orderTypeFileItem = OrderTypeFileItem.asc
            if colOrderDir == "desc" {
                orderTypeFileItem = .desc
            }

            let data = FileItemDataHelper.findAll(searchText: searchValue, offset: start, limit: end, orderBy: orderByFileItem, orderType: orderTypeFileItem)
            let output = FileItemDataTablesOutput()
            
            data.forEach {
                let item = FileItemUpload()
                item.filename = "\($0.filename).\($0.pathExtension)"
                item.filesize = $0.filesize
                item.datetime = $0.datetime
                output.data.append(item)
            }

            output.recordsTotal = recordsTotal
            output.recordsFiltered = recordsTotal
            output.draw = draw
            
            return GCDWebServerDataResponse(jsonObject: output.makeDictionary())
            } as GCDWebServerProcessBlock)
        
        self.webUploader.addHandler(forMethod: "GET", path: "/download", request: GCDWebServerRequest.self, processBlock: { (request: GCDWebServerRequest?) -> GCDWebServerResponse? in                    
            return self.webUploader.downloadFile(_: request!)
            } as GCDWebServerProcessBlock)
        
        self.webUploader.addHandler(forMethod: "POST", path: "/upload", request: GCDWebServerMultiPartFormRequest.self,processBlock: { (request: GCDWebServerRequest?) -> GCDWebServerResponse? in
            let multipartRequest = request as! GCDWebServerMultiPartFormRequest
            
            self.webUploader.uploadFile(_: multipartRequest)
            
            let dict = ["success": true ]
            let data = GCDWebServerDataResponse(jsonObject: dict, contentType: "application/json")!
            return data
            } as GCDWebServerProcessBlock)
        
        self.webUploader.addHandler(forMethod: "UPDATE", path: "/reloadData", request: GCDWebServerMultiPartFormRequest.self,processBlock: { (request: GCDWebServerRequest?) -> GCDWebServerResponse? in
            self.log.info("delegate.reloadData()")
            
            let data = GCDWebServerDataResponse(jsonObject: [:], contentType: "application/json")!
            return data
            } as GCDWebServerProcessBlock)
        
        var address = ""
        do {
            try self.webUploader.start(options: [GCDWebServerOption_ConnectionClass: FileItemGCDWebServerConnection.self])
            
            address = self.webUploader.serverURL != nil ? (self.webUploader.serverURL?.absoluteString)! : ""
            self.log.info("address = \(address)")
        } catch {
            self.log.error(error)
        }
        return address
    }
    
    func stop() {
        self.webUploader.stop()
    }
}
