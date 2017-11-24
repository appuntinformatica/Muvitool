import UIKit
import SQLite
import XCGLogger

typealias FileItem = (
    id:            Int64,
    filename:      String,
    pathExtension: String,
    uuid:          String,
    filesize:      Int64,
    datetime:      Date
)

enum OrderByFileItem {
    case filename
    case filesize
    case datetime
}

enum OrderTypeFileItem {
    case asc
    case desc
}

class FileItemDataHelper: DataHelperProtocol {

    static let log = XCGLogger.default
    let log = XCGLogger.default
    
    static let table         = Table("file_item")
    static let id            = Expression<Int64>("id")
    static let filename      = Expression<String>("filename")
    static let pathExtension = Expression<String>("path_extension")
    static let uuid          = Expression<String>("uuid")
    static let filesize      = Expression<Int64>("filesize")
    static let datetime      = Expression<Date>("datetime")

    typealias T = FileItem
    
    private static func getFileItem(_ item: Row) -> FileItem {
        return FileItem(id: item[id], filename: item[filename], pathExtension: item[pathExtension], uuid: item[uuid], filesize: item[filesize], datetime: item[datetime])
    }
    
    private static func setFileItem(_ item: T) -> [Setter] {
        return [ filename <- item.filename, pathExtension <- item.pathExtension, uuid <- item.uuid, filesize <- item.filesize, datetime <- item.datetime ]
    }
    
    static func createTable() {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            try DB.run( table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: true)
                t.column(filename)
                t.column(pathExtension)
                t.column(uuid)
                t.column(filesize)
                t.column(datetime)
            })
        } catch {
            self.log.error(error)
        }
    }
    
    static func insert(_ item: T) -> Int64 {
        var id: Int64 = 0
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let insert = table.insert(setFileItem(item))
            id = try DB.run(insert)
        } catch {
            log.error(error)
        }
        return id
    }
    
    static func delete(_ item: T) -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(item.id == rowid)
            
            return try DB.run(query.delete())
        } catch {
            self.log.error(error)
            return -1
        }
    }
    
    static func update(_ item: T) -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(item.id == rowid)
            
            return try DB.run(query.update(setFileItem(item)))
        } catch {
            self.log.error(error)
            return -1
        }
    }

    static func find(withId id: Int64) -> T? {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(id == rowid)
            
            let items = try DB.prepare(query)
            
            for item in items {
                return getFileItem(item)
            }
        } catch {
            self.log.error(error)
        }
        return nil
    }
    
    static func findAll() -> [T] {
        var retArray = [T]()
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!

            let items = try DB.prepare(table)
            
            for item in items {
                retArray.append(getFileItem(item))
            }
        } catch {
            log.error(error)
        }
        return retArray
    }
    
    static func getRecordsTotal() -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let count = try DB.scalar(table.count)
            
            return count
        } catch {
            log.error(error)
        }
        return 0
    }

    static func find(byFilename filename: String) -> T? {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(FileItemDataHelper.filename == filename)
            
            let items = try DB.prepare(query)
            
            for item in items {
                return getFileItem(item)
            }
        } catch {
            log.error(error)
        }
        return nil
    }

    static func findAll(searchText: String, offset: Int, limit: Int, orderBy: OrderByFileItem, orderType: OrderTypeFileItem) -> [T] {
        var retArray = [T]()
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            var query: Table!
            if searchText == "" {
                query = table
            } else {
                query = table.filter(filename.lowercaseString.like(searchText.lowercased()))
            }
            switch orderBy {
            case .filename:
                if orderType == .asc {
                    query = query.order(filename.asc)
                } else {
                    query = query.order(filename.desc)
                }
                break
            case .filesize:
                if orderType == .asc {
                    query = query.order(filesize.asc)
                } else {
                    query = query.order(filesize.desc)
                }
                break
            case .datetime:
                if orderType == .asc {
                    query = query.order(datetime.asc)
                } else {
                    query = query.order(datetime.desc)
                }
                break
            }
            self.log.info(query.asSQL())
            
            let items = try DB.prepare(query)
            
            for item in items {
                retArray.append(getFileItem(item))
            }
        } catch {
            log.error(error)
        }
        return retArray
    }
}
