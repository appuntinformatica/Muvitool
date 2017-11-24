import UIKit
import SQLite
import XCGLogger

typealias Bookmark = (
    id:           Int64,
    parentId:     Int64,
    isFolder:     Bool,
    displayOrder: Int,
    title:        String,
    url:          String    
)

class BookmarkDataHelper: DataHelperProtocol {
    static let log = XCGLogger.default
    let log = XCGLogger.default
    
    static let table        = Table("bookmark")
    static let id           = Expression<Int64>("id")
    static let parentId     = Expression<Int64>("parent_id")
    static let isFolder     = Expression<Bool>("is_folder")
    static let displayOrder = Expression<Int>("display_order")
    static let title        = Expression<String>("title")
    static let url          = Expression<String>("url")    
    
    typealias T = Bookmark
    
    private static func getBookmark(_ item: Row) -> Bookmark {
        return Bookmark(id: item[BookmarkDataHelper.id], parentId: item[parentId], isFolder: item[isFolder], displayOrder: item[displayOrder], title: item[title], url: item[url])
    }
    
    private static func setBookmark(_ item: T) -> [Setter] {
        return [ parentId <- item.parentId, isFolder <- item.isFolder, displayOrder <- item.displayOrder, title <- item.title, url <- item.url ]
    }
    
    static func createTable() {
        let DB = SQLiteDataStore.sharedInstance.BBDB!
        var exists = false
        do {
            exists = try DB.scalar(table.exists)
        } catch { }
        self.log.info("exists = \(exists)")
        do {
            try DB.run( table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: true)
                t.column(parentId)
                t.column(isFolder)
                t.column(displayOrder)
                t.column(title)
                t.column(url)
            })
            
            if exists == false {
                self.log.info("Insert defaults bookmarks:")
                self.log.info("Google      -> \(self.insert( Bookmark(id: 0, parentId: 0, isFolder: false, displayOrder: 1, title: "Google", url: "https://www.google.com") ))" )
                self.log.info("Youtube     -> \(self.insert( Bookmark(id: 0, parentId: 0, isFolder: false, displayOrder: 2, title: "Youtube", url: "https://www.youtube.com") ))" )
                self.log.info("Facebook    -> \(self.insert( Bookmark(id: 0, parentId: 0, isFolder: false, displayOrder: 3, title: "Facebook", url: "https://www.facebook.com") ))" )
                self.log.info("Instagram   -> \(self.insert( Bookmark(id: 0, parentId: 0, isFolder: false, displayOrder: 4, title: "Instagram", url: "https://www.instagram.com") ))" )
                self.log.info("Vimeo       -> \(self.insert( Bookmark(id: 0, parentId: 0, isFolder: false, displayOrder: 5, title: "Vimeo", url: "https://vimeo.com") ))" )
                self.log.info("Dailymotion -> \(self.insert( Bookmark(id: 0, parentId: 0, isFolder: false, displayOrder: 6, title: "Dailymotion", url: "http://www.dailymotion.com") ))" )
            }
        } catch {
            self.log.error(error)
        }
    }
    
    static func insert(_ item: T) -> Int64 {
        var id: Int64 = 0
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let insert = table.insert(setBookmark(item))
            
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
            
            return try DB.run(query.update(setBookmark(item)))
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
                return getBookmark(item)
            }
        } catch {
            log.error(error)
        }
        return nil
    }
    
    static func findAll() -> [T] {
        return findAll(byParentId: 0)
    }
    
    static func findAll(byParentId parentId: Int64) -> [T] {
        var retArray = [T]()
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(BookmarkDataHelper.parentId == parentId).order(displayOrder)
            self.log.info(query.asSQL())
            
            let items = try DB.prepare(query)
            
            for item in items {
                retArray.append(getBookmark(item))
            }
        } catch {
            log.error(error)
        }
        return retArray
    }
    
    static func findDisplayOrder(withParentId parentId: Int64, isFolder: Bool) -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.count.filter(BookmarkDataHelper.parentId == parentId && BookmarkDataHelper.isFolder == isFolder)
            self.log.info(query.asSQL())
            
            let items = try DB.prepare(query)
            
            for item in items {
                let displayOrder = item[BookmarkDataHelper.displayOrder] + 1
                return displayOrder
            }
        } catch {
            log.error(error)
        }
        return 0
    }
    
    static func reorder(_ bookmarks: [Bookmark]) {
        let DB = SQLiteDataStore.sharedInstance.BBDB!
        for (index, bookmark) in bookmarks.enumerated() {
            do {
                let e = table.filter(bookmark.id == rowid)
                try DB.run(e.update(displayOrder <- index))
            } catch {
                log.error(error)
            }
        }
    }
}
