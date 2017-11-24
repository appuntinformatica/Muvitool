import UIKit
import XCGLogger

extension UINavigationBar {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        if let superview = self.superview {
            return CGSize(width: superview.frame.size.width, height: 35)
        } else {
            return size
        }
    }
}

class ViewController: UITabBarController {
    let log = XCGLogger.default
    
    let sizeImage = CGFloat(23)
    
    let videoLibraryVC = VideoLibraryViewController()
    let musicLibraryVC = MusicLibraryViewController()
    let playlistVC     = PlaylistViewController()
    let settingsVC     = SettingsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoLibraryItem = UINavigationController(rootViewController: videoLibraryVC)
        videoLibraryItem.tabBarItem = UITabBarItem(title: Strings.Video, image: UIImage(named: "video_library")?.resize(self.sizeImage, self.sizeImage), tag: 2)
        
        let musicLibraryItem = UINavigationController(rootViewController: musicLibraryVC)
        musicLibraryItem.tabBarItem = UITabBarItem(title: Strings.Music, image: UIImage(named: "music_library")?.resize(self.sizeImage, self.sizeImage), tag: 4)
        
        let playlistItem = UINavigationController(rootViewController: playlistVC)
        playlistItem.tabBarItem = UITabBarItem(title: Strings.Playlist, image: UIImage(named: "playlist")?.resize(self.sizeImage, self.sizeImage), tag: 4)
        
        let settingsItem = UINavigationController(rootViewController: settingsVC)
        settingsItem.tabBarItem = UITabBarItem(title: Strings.Settings, image: UIImage(named: "settings")?.resize(self.sizeImage, self.sizeImage), tag: 6)

        self.viewControllers = [ videoLibraryItem, musicLibraryItem, playlistItem, settingsItem ]
   
        var dictionary = [String: Any]()
        dictionary["User Agent"] = "Safari Mobile"
        
        UserDefaults.standard.register(defaults: dictionary)        
    }
    
}
