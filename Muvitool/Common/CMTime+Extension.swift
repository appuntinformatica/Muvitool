import UIKit
import AVFoundation

extension CMTime {
    var durationText:String {
        if !self.isIndefinite {
            let totalSeconds = CMTimeGetSeconds(self)
            let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(totalSeconds)
            if hours > 0 {
                return String(format: "%i:%02i:%02i", hours, minutes, seconds)
            } else {
                return String(format: "%02i:%02i", minutes, seconds)
            }
        } else {
            return ""
        }
    }
    
    func secondsToHoursMinutesSeconds (_ totalSeconds : Double) -> (Int, Int, Int) {
        let (hr,  minf) = modf (totalSeconds / 3600)
        let (min, secf) = modf (60 * minf)
        return (Int(hr), Int(min), Int(60 * secf))
    }
}
