import UIKit

extension Date {
    func currentTimeZoneDate() -> String {
        let df = DateFormatter()
        df.timeZone = TimeZone.current
        //dtf.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
        return df.string(from: self)
    }
    
    func formatDateHuman() -> String {
        let df = DateFormatter()
        df.dateStyle = .full
        return df.string(from: self)
    }

    init(_ dateString: String) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let date = df.date(from: dateString)
        self.init(timeInterval: 0, since: date!)
    }

}
