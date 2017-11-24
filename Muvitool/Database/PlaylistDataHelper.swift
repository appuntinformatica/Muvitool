import UIKit
import SQLite
import XCGLogger

typealias Playlist = (
    id:          Int64,
    description: String,
    displayOrder: Int
)

class PlaylistDataHelper: DataHelperProtocol {
    static let log = XCGLogger.default
    let log = XCGLogger.default

    static let table        = Table("playlist")
    static let id           = Expression<Int64>("id")
    static let description  = Expression<String>("description")
    static let displayOrder = Expression<Int>("display_order")
    
    typealias T = Playlist
    
    private static func getPlaylist(_ item: Row) -> Playlist {
        return Playlist(id: item[PlaylistDataHelper.id], description: item[description], displayOrder: item[displayOrder])
    }
    
    private static func setPlaylist(_ item: T) -> [Setter] {
        return [ description <- item.description, displayOrder <- item.displayOrder ]
    }
    
    static func createTable() {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            try DB.run( table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: true)
                t.column(description)
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
            
            let insert = table.insert(setPlaylist(item))
            
            id = try DB.run(insert)
        } catch {
            self.log.error(error)
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
    
    static func deleteAll() -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            let query = table.delete()
            self.log.info(query.asSQL())
            
            return try DB.run(query)
        } catch {
            self.log.error(error)
            return -1
        }
    }

    static func update(_ item: T) -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(item.id == rowid)
            
            return try DB.run(query.update(setPlaylist(item)))
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
                return getPlaylist(item)
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
         
            let query = table.order(displayOrder)
            self.log.info(query.asSQL())
            
            let items = try DB.prepare(query)

            for item in items {
                retArray.append(getPlaylist(item))
            }
        } catch {
            log.error(error)
        }
        return retArray
    }
    
    static func reorder(_ playlists: [Playlist]) {
        let DB = SQLiteDataStore.sharedInstance.BBDB!
        for (index, playlist) in playlists.enumerated() {
            do {
                let e = table.filter(playlist.id == rowid)
                try DB.run(e.update(displayOrder <- index))
            } catch {
                log.error(error)
            }
        }
    }
}
