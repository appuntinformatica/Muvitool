import UIKit
import SQLite
import XCGLogger

typealias PlaylistItem = (
    id:           Int64,
    playlistId:   Int64,
    filename:     String,
    displayOrder: Int
)

class PlaylistItemDataHelper: DataHelperProtocol {
    static let log = XCGLogger.default
    let log = XCGLogger.default
    
    static let table        = Table("playlist_item")
    static let id           = Expression<Int64>("id")
    static let playlistId   = Expression<Int64>("playlist_id")
    static let filename     = Expression<String>("filename")
    static let displayOrder = Expression<Int>("display_order")
    
    typealias T = PlaylistItem
    
    private static func getPlaylistItem(_ item: Row) -> PlaylistItem {
        return PlaylistItem(id: item[PlaylistItemDataHelper.id], playlistId: item[playlistId], filename: item[filename], displayOrder: item[displayOrder])
    }
    
    private static func setPlaylistItem(_ item: T) -> [Setter] {
        return [ playlistId <- item.playlistId, filename <- item.filename, displayOrder <- item.displayOrder ]
    }
    
    static func createTable() {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            try DB.run( table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: true)
                t.column(playlistId)
                t.column(filename)
                t.column(displayOrder)
            })
        } catch {
            self.log.error(error)
        }
    }
    
    static func insert(_ item: T) -> Int64 {
        var id: Int64 = 0
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let insert = table.insert(setPlaylistItem(item))
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
            log.error(error)
            return -1
        }
    }
    
    static func delete(byFilename filename: String) -> Bool {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(filename == PlaylistItemDataHelper.filename)
            
            let numbersOfDeleted = try DB.run(query.delete())
            self.log.info("numbersOfDeleted = \(numbersOfDeleted)")
            return true
        } catch {
            log.error(error)
            return false
        }
    }
    
    static func delete(withPlaylistId playlistId: Int64) -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(playlistId == PlaylistItemDataHelper.playlistId)
            
            return try DB.run(query.delete())
        } catch {
            log.error(error)
            return -1
        }
    }

    static func update(_ item: T) -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(item.id == rowid)
            
            return try DB.run(query.update(setPlaylistItem(item)))
        } catch {
            log.error(error)
            return -1
        }
    }
    
    static func updateFilename(_ oldFilename: String, _ newFilename: String) -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(oldFilename == PlaylistItemDataHelper.filename).update([filename <- newFilename])
            self.log.info(query.asSQL())

            return try DB.run(query)
        } catch {
            log.error(error)
            return -1
        }
    }
    
    static func find(withId id: Int64) -> T? {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(id == rowid)
            
            let items = try DB.prepare(query)
            
            for item in items {
                return getPlaylistItem(item)
            }
        } catch {
            self.log.error(error)
        }
        return nil
    }
    
    static func findAll() -> [T] {
        return findAll(byPlaylistId: 0)
    }
    
    static func findAll(byPlaylistId playlistId: Int64) -> [T] {
        var retArray = [T]()
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(PlaylistItemDataHelper.playlistId == playlistId).order(displayOrder)
            self.log.info(query.asSQL())
            
            let items = try DB.prepare(query)
            
            for item in items {
                retArray.append(getPlaylistItem(item))
            }
        } catch {
            self.log.error(error)
        }
        return retArray
    }

    static func reorder(_ playlistId: Int64, _ playlistItems: [PlaylistItem]) {
        let DB = SQLiteDataStore.sharedInstance.BBDB!
        for (index, playlistItem) in playlistItems.enumerated() {
            do {
                let e = table.filter(playlistItem.id == rowid)
                try DB.run(e.update(displayOrder <- index))
            } catch {
                self.log.error(error)
            }
        }
    }
    
    static func getCount(byPlaylistId playlistId: Int64) -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(PlaylistItemDataHelper.playlistId == playlistId).count
            self.log.info(query.asSQL())
            return try DB.scalar(query)
        } catch {
            self.log.error(error)
            return -1
        }
    }
    
    static func getCount(byFilename filename: String) -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(PlaylistItemDataHelper.filename == filename).count
            self.log.info(query.asSQL())
            return try DB.scalar(query)
        } catch {
            self.log.error(error)
            return -1
        }
    }
}
