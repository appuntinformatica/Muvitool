import UIKit
import GCDWebServer
import XCGLogger

class MyGCDWebServerConnection: GCDWebServerConnection {
    override func processRequest(_ request: GCDWebServerRequest!, completion: GCDWebServerCompletionBlock!) {
        if let multipartRequest = request as? GCDWebServerMultiPartFormRequest {
            if let multipartFile = multipartRequest.files?.first as? GCDWebServerMultiPartFile {
                var userInfo = [ AnyHashable: Any ]()
                userInfo["filename"] = multipartFile.fileName
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WebUploaderFinished"), object: self, userInfo: userInfo)
            }
        }
        super.processRequest(request, completion: completion)
    }
}

class WebUploader: NSObject {
    let log = XCGLogger.default
    
    var uploadDirectory: String!
    var multimediaArray: Array<FileItemUpload>!
    
    init(uploadDirectory: String, multimediaArray: Array<FileItemUpload>) {
        super.init()
        self.uploadDirectory = uploadDirectory
        self.multimediaArray = multimediaArray
    }
    
    var webUploader: GCDWebUploader!

    func start() -> String {
        self.webUploader = GCDWebUploader(uploadDirectory: self.uploadDirectory)
        
        let directoryPath = "\(Bundle.main.bundlePath)/Website"
        log.info("directoryPath = \(directoryPath)")
        
        self.webUploader.addGETHandler(forBasePath: "/", directoryPath: directoryPath, indexFilename: "index.html", cacheAge: 0, allowRangeRequests: true)
        
        self.webUploader.addHandler(forMethod: "GET", path: "/list", request: GCDWebServerRequest.self, processBlock: { (request: GCDWebServerRequest?) -> GCDWebServerResponse? in
            var start = 0, length = 0, draw = 0, colOrderIndex = 0
            var searchValue = "", colOrderDir = ""
            
            request?.query.forEach({ e in
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
            let recordsTotal = self.multimediaArray.count
            
            var data = self.multimediaArray.sorted(by: { (vm1, vm2) in
                switch (colOrderIndex) {
                case 0:
                    if colOrderDir == "asc" {
                        return vm1.filename.compare(vm2.filename) == ComparisonResult.orderedAscending
                    } else {
                        return vm1.filename.compare(vm2.filename) == ComparisonResult.orderedDescending
                    }
                case 1:
                    if colOrderDir == "asc" {
                        return vm1.filesize < vm2.filesize
                    } else {
                        return vm1.filesize > vm2.filesize
                    }
                case 2:
                    if colOrderDir == "asc" {
                        return vm1.datetime.compare(vm2.datetime) == ComparisonResult.orderedAscending
                    } else {
                        return vm1.datetime.compare(vm2.datetime) == ComparisonResult.orderedDescending
                    }
                default:
                    return false
                }
            })
            if searchValue != "" {
                data = data.filter({
                    return $0.filename.uppercased().contains(searchValue.uppercased())
                })
            }
            
            let output = DataTablesOutput()
            
            for (index, item) in data.enumerated() {
                if start <= index && index < end {
                    output.data.append(item)
                }
            }
            output.recordsTotal = recordsTotal
            output.recordsFiltered = recordsTotal
            output.draw = draw
            
            return GCDWebServerDataResponse(jsonObject: output.makeDictionary())
        } as GCDWebServerProcessBlock)
        
        self.webUploader.addHandler(forMethod: "GET", path: "/download", request: GCDWebServerRequest.self, processBlock: { (request: GCDWebServerRequest?) -> GCDWebServerResponse? in
                return self.webUploader.downloadFile(_: request)
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
            
            AudioFileManager.shared.reloadData()
            self.multimediaArray = AudioFileManager.shared.data
            
            let data = GCDWebServerDataResponse(jsonObject: [:], contentType: "application/json")!
            return data
        } as GCDWebServerProcessBlock)

        var address = ""
        do {	
            try self.webUploader.start(options: [GCDWebServerOption_ConnectionClass: MyGCDWebServerConnection.self])
            
            address = self.webUploader.serverURL != nil ? self.webUploader.serverURL.absoluteString : ""
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
