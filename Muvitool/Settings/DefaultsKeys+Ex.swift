import UIKit
import SwiftyUserDefaults
import XCGLogger

let SearchEngines: [String: String] = [
    "Google"      : "https://www.google.com/search?q=",
    "Yahoo"       : "https://search.yahoo.com/search?p=",
    "Bing"        : "https://www.bing.com/search?q=",
    "Youtube"     : "https://www.youtube.com/results?search_query=",
    "Dailymotion" : "https://www.dailymotion.com/search/",
    "Vimeo"       : "https://vimeo.com/search?q=",
    "DuckDuckGo"  : "https://duckduckgo.com/?q=",
    "Ask"         : "http://www.ask.com/web?q="
]

extension DefaultsKeys {
    static let log = XCGLogger.default

    private static let homePage = DefaultsKey<String>("homePage")
    static func setHomePage(_ value: String) {
        Defaults[DefaultsKeys.homePage] = value
    }    
    static func getHomePage() -> String {
        if Defaults[DefaultsKeys.homePage] == "" {
            self.log.info("homePage is empty")
            Defaults[DefaultsKeys.homePage] = "https://www.google.com"
            self.log.info("--> \(Defaults[DefaultsKeys.homePage])")
        }
        return Defaults[DefaultsKeys.homePage]
    }
    
    private static let searchEngine = DefaultsKey<String>("searchEngine")
    static func setSearchEngine(_ value: String) {
        Defaults[DefaultsKeys.searchEngine] = value
    }
    static func getSearchEngine() -> String {
        if Defaults[DefaultsKeys.searchEngine] == "" {
            self.log.info("searchEngine is empty")
            Defaults[DefaultsKeys.searchEngine] = "Google"
        }
        return Defaults[DefaultsKeys.searchEngine]
    }
    
    private static let allowDownloadVideo     = DefaultsKey<Bool?>("allowDownloadVideo")
    static func setAllowDownloadVideo(_ value: Bool) {
        Defaults[DefaultsKeys.allowDownloadVideo] = value
    }
    static func isAllowDownloadVideo() -> Bool {
        if Defaults[DefaultsKeys.allowDownloadVideo] == nil {
            self.log.info("allowDownloadVideo is empty")
            Defaults[DefaultsKeys.allowDownloadVideo] = true
        }
        return Defaults[DefaultsKeys.allowDownloadVideo]!
    }
    
    private static let casualNextPlay = DefaultsKey<Bool?>("casualNextPlay")
    static func setCasualNextPlay(_ value: Bool) {
        Defaults[DefaultsKeys.casualNextPlay] = value
    }
    static func isCasualNextPlay() -> Bool {
        if Defaults[DefaultsKeys.casualNextPlay] == nil {
            self.log.info("casualNextPlay is empty")
            Defaults[DefaultsKeys.casualNextPlay] = false
        }
        return Defaults[DefaultsKeys.casualNextPlay]!
    }

}
