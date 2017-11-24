import UIKit
import SQLite
import XCGLogger

typealias AppConfig = (
    id:     Int64,
    key:    String,
    value:  String
)

class AppConfigDataHelper: DataHelperProtocol {
    static let log = XCGLogger.default
    let log = XCGLogger.default
    
    static let databaseSchemaVersionKey          = "databaseSchemaVersion"

    
    static let table = Table("app_config")
    static let id    = Expression<Int64>("id")
    static let key   = Expression<String>("app_config_key")
    static let value = Expression<String>("app_config_value")
    
    typealias T = AppConfig
    
    static func createTable() {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            try DB.run( table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: true)
                t.column(key)
                t.column(value)
            })

            self.log.info( insert(AppConfig(id: 0, key: databaseSchemaVersionKey, value: "1")) )
        } catch {
            self.log.error(error)
        }
    }
    
    static func insert(_ item: T) -> Int64 {
        var id: Int64 = 0
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let insert = table.insert(key <- item.key, value <- item.value)
            
            id = try DB.run(insert)
        } catch {
            log.error(error)
        }
        return id
    }
    
    static func delete(_ item: T) -> Int{
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
            
            return try DB.run(query.update(key <- item.key, value <- item.value))
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
                return AppConfig(id: item[AppConfigDataHelper.id], key: item[key], value: item[value])
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
                retArray.append(AppConfig(id: item[AppConfigDataHelper.id], key: item[key], value: item[value]))
            }
        } catch {
            self.log.error(error)
        }
        return retArray
    }
    
    static func find(byKey keyInput: String) -> T? {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(keyInput == key)
            
            let items = try DB.prepare(query)
            
            for item in items {
                return AppConfig(id: item[AppConfigDataHelper.id], key: item[key], value: item[value])
            }
        } catch {
            self.log.error(error)
        }
        return nil
    }
    
    
}
