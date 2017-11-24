import UIKit
import XCGLogger
import AudioPlayerManager
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate /*, CXCallObserverDelegate */ {
    let log = XCGLogger.default
    
    var window: UIWindow?
    var viewController: ViewController!
    var backgroundSessionCompletionHandler : (() -> Void)?
    var callObserver = CXCallObserver()
    var lastStatePlaying: Bool?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let s = SQLiteDataStore.sharedInstance
        s.createTables()
        
        AudioPlayerManager.shared.setup()
        AudioFileManager.shared.reloadData()
        
      //  callObserver.setDelegate(self, queue: nil)        
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.white
        self.viewController = ViewController()
        self.window!.rootViewController = self.viewController
        self.window!.makeKeyAndVisible()
        
        application.beginBackgroundTask(withName: "showN", expirationHandler: nil)
        
        return true
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        AudioPlayerManager.shared.remoteControlReceivedWithEvent(event)
    }
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if self.lastStatePlaying == nil {
            self.lastStatePlaying = AudioPlayerManager.shared.isPlaying()
            self.log.info("lastStatePlaying = \(String(describing: self.lastStatePlaying))")
        }
        var userInfo = [ AnyHashable: Any ]()
        userInfo["text"] = "uuid = \(call.uuid), hasConnected = \(call.hasConnected), isOutgoing = \(call.isOutgoing), hasEnded = \(call.hasEnded), isOnHold = \(call.isOnHold)"

        if call.hasConnected {
            self.log.info("call connected: \(call.uuid)")
        }
        if call.isOutgoing {
            self.log.info("call outgoing: \(call.uuid)")
        }
        if call.hasEnded {
            self.log.info("call hasEnded: \(call.uuid)")
            if self.lastStatePlaying != nil, self.lastStatePlaying! {
                NotificationCenter.default.post(Notification(name: PlayerViewController.PlayNotification))
            }
            self.lastStatePlaying = nil
        }
        if call.isOnHold {
            self.log.info("call onHold: \(call.uuid)")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if UIApplication.shared.applicationIconBadgeNumber > 0 {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

