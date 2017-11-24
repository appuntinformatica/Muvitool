import UIKit

protocol DataHelperProtocol {
    associatedtype T
    static func createTable()   -> Void
    static func insert(_ item: T) -> Int64
    static func delete(_ item: T) -> Int
    static func update(_ item: T) -> Int
    static func findAll()       -> [T]
    static func find(withId id: Int64) -> T?
}
