import AVFoundation
import UIKit

extension AVAsset {
    func writeAudioTrack(to url: URL, success: @escaping () -> (), failure: @escaping (Error) -> (), updateProgress: @escaping (Float) -> ()) {
        do {
            let asset = try audioAsset()
            asset.write(to: url, success: success, failure: failure, updateProgress: updateProgress)
        } catch {
            failure(error)
        }
    }
    
    private func write(to url: URL, success: @escaping () -> (), failure: @escaping (Error) -> (), updateProgress: @escaping (Float) -> ()) {
        guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetAppleM4A) else {
            let error = NSError(domain: "domain", code: 0, userInfo: nil)
            failure(error)
            
            return
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            updateProgress(exportSession.progress)
        })
        
        
        exportSession.outputFileType = AVFileTypeAppleM4A
        
        exportSession.outputURL = url
        
        exportSession.exportAsynchronously {
            timer.invalidate()
            switch exportSession.status {                
            case .completed:
                success()
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                let error = NSError(domain: "domain", code: 0, userInfo: nil)
                failure(error)
            }
        }
    }
    
    private func audioAsset() throws -> AVAsset {
        let composition = AVMutableComposition()
        let audioTracks = tracks(withMediaType: AVMediaTypeAudio)
        
        for track in audioTracks {
            let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try compositionTrack.insertTimeRange(track.timeRange, of: track, at: track.timeRange.start)
            } catch {
                throw error
            }
            compositionTrack.preferredTransform = track.preferredTransform
        }
        
        return composition
    }
}
