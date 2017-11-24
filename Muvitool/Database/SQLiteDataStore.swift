import Foundation
import SQLite
import XCGLogger


enum DataAccessError: Error {
    case Datastore_Connection_Error
    case Insert_Error
    case Delete_Error
    case Search_Error
    case Nil_In_Data
}

class SQLiteDataStore {
    static let sharedInstance = SQLiteDataStore()
    
    let log = XCGLogger.default

    let BBDB: Connection?
    
    private init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filename = "\(documentsPath)/MuvitoolDB.sqlite"
        self.log.info("filename = \(filename)")
        
        do {
            //try? FileManager.default.removeItem(atPath: filename)
            
            BBDB = try Connection(filename)
        } catch {
            self.log.error(error)
            BBDB = nil
        }
    }
    
    func createTables() {
        AppConfigDataHelper.createTable()
        PlaylistDataHelper.createTable()
        PlaylistItemDataHelper.createTable()
        BookmarkDataHelper.createTable()
        HistoryDataHelper.createTable()
    }

    func upgradeDatabaseIfNeeded() {
        var appConfig = AppConfigDataHelper.find(byKey: AppConfigDataHelper.databaseSchemaVersionKey)
        let databaseSchemaVersionValue = Int( (appConfig?.value)! )!
        
        if databaseSchemaVersionValue < 3 {
            if databaseSchemaVersionValue < 2 {
                if databaseSchemaVersionValue < 1 {
                    // run statements to upgrade from 0 to 1
                }
                // run statements to upgrade from 1 to 2
            }
            // run statements to upgrade from 2 to 3
            
            // and so on...
            
            // set this to the latest version number
            
            //  [self setDatabaseSchemaVersion:3];
            appConfig?.value = "3"
            self.log.info("AppConfigDataHelper.update: \(AppConfigDataHelper.update(appConfig!))")
        }
    }
    
    func migrate(fromVersion version1: Int, toVersion version2: Int) {
        do {
            try BBDB?.execute(
                "BEGIN TRANSACTION;" +
                    "CREATE TABLE t1_backup(a,b);" +
                    "INSERT INTO t1_backup SELECT a,b FROM t1;" +
                    "DROP TABLE t1;" +
                    "ALTER TABLE t1_backup RENAME TO t1;" +
                "COMMIT TRANSACTION;"
            )
        } catch {
            self.log.error(error)
        }
    }
}
