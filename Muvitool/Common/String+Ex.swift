import UIKit

extension String {
    
    func startsWith(string: String) -> Bool {
        guard let range = range(of: string, options:[.caseInsensitive]) else {
            return false
        }
        return range.lowerBound == startIndex
    }
    
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }

    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }

    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }

    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
    mutating func renamedIfNotUnique() {
        let ranges = self.ranges(of: "(?<=\\().*?(?=\\))", options: .regularExpression)
        var replaced = false
        if let range = ranges.last {
            if self.distance(from: startIndex , to: range.upperBound) == self.characters.count - 1 {
                if let n = Int(self.substring(with: range)) {
                    self.replaceSubrange(range, with: "\(n + 1)")
                    replaced = true
                }
            }
        }
        if !replaced {
            self = "\(self) (0)"
        }
    }
    
    func getPathExtension() -> String {
        return (self as NSString).pathExtension
    }
    
    func deletingPathExtension() -> String {
        return (self as NSString).deletingPathExtension
    }
    
    func appendingRandomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return self.appending(randomString)
    }
    
    func deleteCharacters(_ strings: [String]) -> String {
        var s = self
        strings.forEach {
            s = s.replacingOccurrences(of: $0, with: "", options: NSString.CompareOptions.literal, range:nil)
        }
        return s
    }
    
    func convertHtmlSymbols() -> String {
        // https://dev.w3.org/html5/html-author/charref
        var htmlConverted = self.replacingOccurrences(of: "\n", with: "<br/>")
        htmlConverted = htmlConverted.replacingOccurrences(of: "&", with: "&amp;")
        htmlConverted = htmlConverted.replacingOccurrences(of: "<", with: "&lt;")
        htmlConverted = htmlConverted.replacingOccurrences(of: ">", with: "&gt;")
        
        var specialChars = [ String: String ]()
        specialChars["!"] = "&excl;"
        specialChars["€"] = "&euro;"
        specialChars["%"] = "&percnt;"
        specialChars["'"] = "&apos;"
        specialChars["\""] = "&quot;"
        specialChars["#"] = "&num;"
        specialChars["$"] = "&dollar;"
        specialChars["("] = "&lpar;"
        specialChars[")"] = "&rpar;"
        specialChars["*"] = "&ast;"
        specialChars["+"] = "&plus;"
        specialChars[","] = "&comma;"
        specialChars["."] = "&period;"
        specialChars["/"] = "&sol;"
        specialChars[":"] = "&colon;"
        specialChars[";"] = "&semi;"
        specialChars["<"] = "&lt;"
        specialChars["="] = "&equals;"
        specialChars[">"] = "&gt;"
        specialChars["?"] = "&quest;"
        specialChars["@"] = "&commat;"
        specialChars["["] = "&lsqb;"
        specialChars["\\"] = "&bsol;"
        specialChars["]"] = "&rsqb;"
        specialChars["^"] = "&Hat;"
        specialChars["_"] = "&lowbar;"
        specialChars["|"] = "&verbar;"
        specialChars[" "] = "&nbsp;"
        specialChars["£"] = "&pound;"
        specialChars["à"] = "&agrave;"
        specialChars["á"] = "&aacute;"
        specialChars["è"] = "&egrave;"
        specialChars["é"] = "&eacute;"
        specialChars["ì"] = "&igrave;"
        specialChars["í"] = "&iacute;"
        specialChars["ò"] = "&ograve;"
        specialChars["ó"] = "&oacute;"
        specialChars["ù"] = "&ugrave;"
        specialChars["ú"] = "&uacute;"
        
        specialChars.forEach {_,_ in 
            //TODO: htmlConverted = htmlConverted.replacingOccurrences(of: $0.key, with: $0.value)
        }
        return htmlConverted
    }
}
