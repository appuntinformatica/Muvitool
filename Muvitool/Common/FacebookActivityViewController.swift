import UIKit

class FacebookActivityViewController: UIActivityViewController {
    
    init(sharingItems: [Any]) {
        super.init(activityItems: sharingItems, applicationActivities: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var excludedActivityTypes: [UIActivityType]? {
        get {
            let list = [
                UIActivityType.assignToContact,
                UIActivityType.print,
                UIActivityType.addToReadingList,
                UIActivityType.saveToCameraRoll,
                UIActivityType.openInIBooks,
//                UIActivityType.postToFacebook,
                UIActivityType.postToTwitter,
                UIActivityType.postToWeibo,
                UIActivityType.postToVimeo,
                UIActivityType.postToFlickr,
                UIActivityType.postToTencentWeibo,
                UIActivityType.airDrop,
                UIActivityType.print,
                UIActivityType.copyToPasteboard,
                UIActivityType.saveToCameraRoll,
                UIActivityType.addToReadingList
            ]
            return list
        }
        set {
            self.excludedActivityTypes = newValue
        }
    }
    
}
