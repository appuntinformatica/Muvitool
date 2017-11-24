import UIKit
import XCGLogger
import SnapKit
import GameplayKit
import AudioPlayerManager
import MediaPlayer
import SwiftyUserDefaults

extension UINavigationController {
    override open var shouldAutorotate: Bool {
        get {
            if let visibleVC = visibleViewController {
                if visibleVC is PlayerViewController {
                    return false
                }
            }
            return super.shouldAutorotate
        }
    }
}

extension AudioPlayerManager {
    public func remoteControlReceivedWithEvent(_ event: UIEvent?) {
        if let _event = event {
            switch _event.subtype {
            case UIEventSubtype.remoteControlPlay:
                NotificationCenter.default.post(Notification(name: PlayerViewController.PlayNotification))
            case UIEventSubtype.remoteControlPause:
                NotificationCenter.default.post(Notification(name: PlayerViewController.PauseNotification))
            case UIEventSubtype.remoteControlNextTrack:
                NotificationCenter.default.post(Notification(name: PlayerViewController.ForwardNotification))
            case UIEventSubtype.remoteControlPreviousTrack:
                NotificationCenter.default.post(Notification(name: PlayerViewController.RewindNotification))
            case UIEventSubtype.remoteControlTogglePlayPause:
                NotificationCenter.default.post(Notification(name: PlayerViewController.TogglePlayPauseNotification))
            default:
                break
            }
        }
    }
}

extension MPVolumeView {
    var volumeSlider: UISlider? {
        showsRouteButton = false
        showsVolumeSlider = false
        isHidden = true
        for subview in subviews where subview is UISlider {
            let slider =  subview as! UISlider
            slider.isContinuous = false
            slider.value = AVAudioSession.sharedInstance().outputVolume
            return slider
        }
        return nil
    }
}

class PlayerViewController: UIViewController {
    let log = XCGLogger.default
    
    static let shared: PlayerViewController = {
        let instance = PlayerViewController()
        return instance
    }()
    
    static let SystemVolumeNotification    = Notification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification")
    static let PlayNotification            = Notification.Name(rawValue: "PlayerViewControllerPlayNotification")
    static let PauseNotification           = Notification.Name(rawValue: "PlayerViewControllerPauseNotification")
    static let ForwardNotification         = Notification.Name(rawValue: "PlayerViewControllerForwardNotification")
    static let RewindNotification          = Notification.Name(rawValue: "PlayerViewControllerRewindNotification")
    static let TogglePlayPauseNotification = Notification.Name(rawValue: "PlayerViewControllerTogglePlayPauseNotification")
    
    var airpodsConnected = false
    
    static let sizeImage     = CGFloat(40)
    static let spacingButton = CGFloat(20)
    
    var currentIndexUrl:         Int = 0
    var urls       = [URL]()
    var randomUrls = [URL]()
    
    let muteOnImage            = UIImage(named: "mute_on")?.resize(sizeImage, sizeImage)
    let muteOffImage           = UIImage(named: "mute_off")?.resize(sizeImage, sizeImage)
    
    let musicImage             = UIImage(named: "music")
    
    let rewindImage            = UIImage(named: "previous")?.resize(sizeImage, sizeImage)
    let playImage              = UIImage(named: "play")?.resize(sizeImage, sizeImage)
    let pauseImage             = UIImage(named: "pause")?.resize(sizeImage, sizeImage)
    let forwardImage           = UIImage(named: "next")?.resize(sizeImage, sizeImage)
    let casualNextPlayOffImage = UIImage(named: "casual_next_play_off")?.resize(sizeImage, sizeImage)
    let casualNextPlayOnImage  = UIImage(named: "casual_next_play_on")?.resize(sizeImage, sizeImage)
    let sameNextPlayOffImage   = UIImage(named: "same_next_play_off")?.resize(sizeImage, sizeImage)
    let sameNextPlayOnImage    = UIImage(named: "same_next_play_on")?.resize(sizeImage, sizeImage)
    
    var isChangeSequence = true
    var isSameNextPlay   = false
    var isCasualNextPlay = false
    var isMute           = false
    
    var artworkImageView:   UIImageView!
    
    var volumeView:         UIView!
    var muteOnOffButton:    UIButton!
    var volumeSlider:       UISlider!

    var controlsView:              UIView!
    var timeSlider:                UISlider!
    var currentTimeLabel:          UILabel!
    var trackDurationLabel:        UILabel!
    var songLabel:                 UILabel!
    var artistLabel:               UILabel!
    
    var buttonsView:               UIView!
    var rewindButton:              UIButton!
    var playPauseButton:           UIButton!
    var forwardButton:             UIButton!
    var casualNextPlayOnOffButton: UIButton!
    var sameNextPlayOnOffButton:   UIButton!

    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.volumeValueChanged(_:)), name: PlayerViewController.SystemVolumeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.didPressForwardButton(_:)), name: PlayerViewController.ForwardNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.didPressRewindButton(_:)), name: PlayerViewController.RewindNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.didPressPlayPauseButton(_:)), name: PlayerViewController.TogglePlayPauseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.didPressPauseRemote), name: PlayerViewController.PauseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.didPressPlayRemote), name: PlayerViewController.PlayNotification, object: nil)
        
        self.initPlaybackTimeViews()
        self.updateButtonStates()
        
        // Listen to the player state updates. This state is updated if the play, pause or queue state changed.
        AudioPlayerManager.shared.addPlayStateChangeCallback(self, callback: { [weak self] (track: AudioTrack?) in
            self?.updateButtonStates()
            self?.updateSongInformation(with: track)
        })
        // Listen to the playback time changed. Thirs event occurs every `AudioPlayerManager.PlayingTimeRefreshRate` seconds.
        AudioPlayerManager.shared.addPlaybackTimeChangeCallback(self, callback: { [weak self] (track: AudioTrack?) in
            self?.updatePlaybackTime(track)
        })
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))

        self.artworkImageView = UIImageView()
        self.artworkImageView.image = self.musicImage
        self.view.addSubview(self.artworkImageView)
        self.artworkImageView.snp.makeConstraints {
            $0.centerY.equalTo(self.view.snp.centerY).offset(-20)
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.width.equalTo(300)
            $0.height.equalTo(300)
        }
        
        self.volumeView = UIView()
        self.view.addSubview(self.volumeView)
        self.volumeView.snp.makeConstraints {
            $0.bottom.equalTo(self.artworkImageView.snp.top).offset(-20)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
            $0.height.equalTo((self.muteOnImage?.size.height)! + 5)
        }

        self.volumeSlider = UISlider()
        self.volumeSlider.addTarget(self, action: #selector(didChangeVolumeSliderValue), for: .valueChanged)
        self.volumeView.addSubview(self.volumeSlider)
        self.volumeSlider.snp.makeConstraints {
            $0.top.equalTo(self.volumeView.snp.top).offset(5)
            $0.left.equalTo(self.volumeView.snp.left).offset(5)
        }
        
        self.muteOnOffButton = UIButton()
        self.muteOnOffButton.addTarget(self, action: #selector(didChangeMuteStateValue), for: .touchUpInside)
        self.muteOnOffButton.setImage(self.muteOffImage, for: .normal)
        self.volumeView.addSubview(self.muteOnOffButton)
        self.muteOnOffButton.snp.makeConstraints {
            $0.top.equalTo(self.volumeView.snp.top).offset(5)
            $0.left.equalTo(self.volumeSlider.snp.right).offset(5)
            $0.right.equalTo(self.volumeView.snp.right).offset(-5)
        }
       
        self.controlsView = UIView()
        self.view.addSubview(self.controlsView)
        self.controlsView.snp.makeConstraints {
            $0.top.equalTo(self.artworkImageView.snp.bottom).offset(5)
            $0.bottom.equalTo(self.view.snp.bottom).offset(-5)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
        }
        
        self.currentTimeLabel = UILabel(frame: CGRect.zero)
        self.currentTimeLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightThin)
        self.currentTimeLabel.text = "--:--"
        self.controlsView.addSubview(self.currentTimeLabel)
        self.currentTimeLabel.snp.makeConstraints {
            $0.top.equalTo(self.controlsView.snp.top).offset(5)
            $0.left.equalTo(self.controlsView.snp.left).offset(5)
        }
        
        self.trackDurationLabel = UILabel(frame: CGRect.zero)
        self.trackDurationLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightThin)
        self.trackDurationLabel.text = "--:--"
        self.controlsView.addSubview(self.trackDurationLabel)
        self.trackDurationLabel.snp.makeConstraints {
            $0.top.equalTo(self.controlsView.snp.top).offset(5)
            $0.right.equalTo(self.controlsView.snp.right).offset(-5)
        }
        
        self.timeSlider = UISlider()
        self.timeSlider.addTarget(self, action: #selector(didChangeTimeSliderValue), for: .valueChanged)
        self.controlsView.addSubview(self.timeSlider)
        self.timeSlider.snp.makeConstraints {
            $0.top.equalTo(self.currentTimeLabel.snp.bottom)
            $0.left.equalTo(self.controlsView.snp.left).offset(5)
            $0.right.equalTo(self.controlsView.snp.right).offset(-5)
        }
        
        self.songLabel = UILabel(frame: CGRect.zero)
        self.songLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.songLabel.textAlignment = .center
        self.songLabel.text = Strings.Title
        self.controlsView.addSubview(self.songLabel)
        self.songLabel.snp.makeConstraints {
            $0.top.equalTo(self.timeSlider.snp.bottom)
            $0.left.equalTo(self.controlsView.snp.left).offset(5)
            $0.right.equalTo(self.controlsView.snp.right).offset(-5)
        }
        
        self.artistLabel = UILabel(frame: CGRect.zero)
        self.artistLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightThin)
        self.artistLabel.textAlignment = .center
        self.artistLabel.text = Strings.Artist
        self.controlsView.addSubview(self.artistLabel)
        self.artistLabel.snp.makeConstraints {
            $0.top.equalTo(self.songLabel.snp.bottom).offset(5)
            $0.left.equalTo(self.controlsView.snp.left).offset(5)
            $0.right.equalTo(self.controlsView.snp.right).offset(-5)
        }
        
        /* Buttons */
        self.buttonsView = UIView()
        self.controlsView.addSubview(self.buttonsView)
        self.buttonsView.snp.makeConstraints {
            $0.left.equalTo(self.controlsView.snp.left)
            $0.right.equalTo(self.controlsView.snp.right)
            $0.bottom.equalTo(self.controlsView.snp.bottom)
            $0.height.equalTo(80)
        }
        
        self.playPauseButton = UIButton()
        self.playPauseButton.addTarget(self, action: #selector(didPressPlayPauseButton), for: .touchUpInside)
        self.playPauseButton.setImage(self.playImage, for: .normal)
        self.buttonsView.addSubview(self.playPauseButton)
        self.playPauseButton.snp.makeConstraints {
            $0.center.equalTo(self.buttonsView.snp.center)
        }

        self.rewindButton = UIButton()
        self.rewindButton.addTarget(self, action: #selector(didPressRewindButton), for: .touchUpInside)
        self.rewindButton.setImage(self.rewindImage, for: .normal)
        self.buttonsView.addSubview(self.rewindButton)
        self.rewindButton.snp.makeConstraints {
            $0.centerY.equalTo(self.buttonsView.snp.centerY)
            $0.right.equalTo(self.playPauseButton.snp.left).offset(-PlayerViewController.spacingButton)
        }

        self.forwardButton = UIButton()
        self.forwardButton.addTarget(self, action: #selector(didPressForwardButton), for: .touchUpInside)
        self.forwardButton.setImage(self.forwardImage, for: .normal)
        self.buttonsView.addSubview(self.forwardButton)
        self.forwardButton.snp.makeConstraints {
            $0.centerY.equalTo(self.buttonsView.snp.centerY)
            $0.left.equalTo(self.playPauseButton.snp.right).offset(PlayerViewController.spacingButton)
        }

        self.sameNextPlayOnOffButton = UIButton()
        self.sameNextPlayOnOffButton.addTarget(self, action: #selector(sameNextPlayOnOffTouchUpInside), for: .touchUpInside)
        self.sameNextPlayOnOffButton.setImage(self.sameNextPlayOffImage, for: .normal)
        self.buttonsView.addSubview(self.sameNextPlayOnOffButton)
        self.sameNextPlayOnOffButton.snp.makeConstraints {
            $0.centerY.equalTo(self.buttonsView.snp.centerY)
            $0.right.equalTo(self.rewindButton.snp.left).offset(-PlayerViewController.spacingButton)
        }

        self.isCasualNextPlay = DefaultsKeys.isCasualNextPlay()
        self.casualNextPlayOnOffButton = UIButton()
        self.casualNextPlayOnOffButton.addTarget(self, action: #selector(PlayerViewController.casualNextPlayOnOffTouchUpInside(_:)), for: .touchUpInside)
        if self.isCasualNextPlay {
            self.casualNextPlayOnOffButton.setImage(self.casualNextPlayOnImage, for: .normal)
        } else {
            self.casualNextPlayOnOffButton.setImage(self.casualNextPlayOffImage, for: .normal)
        }
        self.buttonsView.addSubview(self.casualNextPlayOnOffButton)
        self.casualNextPlayOnOffButton.snp.makeConstraints {
            $0.centerY.equalTo(self.buttonsView.snp.centerY)
            $0.left.equalTo(self.forwardButton.snp.right).offset(PlayerViewController.spacingButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    deinit {
        // Stop listening to the callbacks
        AudioPlayerManager.shared.removePlayStateChangeCallback(self)
        AudioPlayerManager.shared.removePlaybackTimeChangeCallback(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.log.info("volume = \(AVAudioSession.sharedInstance().outputVolume)")
        self.volumeSlider.value = AVAudioSession.sharedInstance().outputVolume
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.log.info("to: \(size)") // fare riferimento a 'to size'
    }

    func initPlaybackTimeViews() {
        self.timeSlider?.value = 0
        self.timeSlider?.maximumValue = 1.0
        self.currentTimeLabel?.text = "-:-"
        self.trackDurationLabel?.text = "-:-"
    }
    
    func updateButtonStates() {
        //self.rewindButton?.isEnabled = AudioPlayerManager.shared.canRewind()
        if AudioPlayerManager.shared.isPlaying() {
            self.playPauseButton?.setImage(self.pauseImage, for: UIControlState())
        } else {
            self.playPauseButton?.setImage(self.playImage, for: UIControlState())
        }
        self.playPauseButton?.isEnabled = AudioPlayerManager.shared.canPlay()
        //self.forwardButton?.isEnabled = AudioPlayerManager.shared.canForward()
    }
    
    func updateSongInformation(with track: AudioTrack?) {
        self.songLabel?.text = "\((track?.nowPlayingInfo?[MPMediaItemPropertyTitle] as? String) ?? "-")"
        //self.albumLabel?.text = "\((track?.nowPlayingInfo?[MPMediaItemPropertyAlbumTitle] as? String) ?? "-")"
        self.artistLabel?.text = "\((track?.nowPlayingInfo?[MPMediaItemPropertyArtist] as? String) ?? "-")"
        let size = self.view.frame.width < self.view.frame.height ? self.view.frame.width - 10 : self.view.frame.height - 10
        if let artwork = track?.nowPlayingInfo?[MPMediaItemPropertyArtwork] as? MPMediaItemArtwork {
            self.artworkImageView.image = artwork.image(at: CGSize.zero)?.resize(size, size)
        } else {
            self.artworkImageView.image = self.musicImage?.resize(size, size)
        }
        self.updatePlaybackTime(track)
    }
    
    func updatePlaybackTime(_ track: AudioTrack?) {
        self.currentTimeLabel?.text = track?.displayablePlaybackTimeString() ?? "-:-"
        self.trackDurationLabel?.text = track?.displayableDurationString() ?? "-:-"
        self.timeSlider?.value = track?.currentProgress() ?? 0
    }
    
    func play(urls: [URL], at index: Int) {
        self.urls = urls
        let sequenceIndexUlrs = [Int](0..<self.urls.count)
        let randomSequenceIndexUrls = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: sequenceIndexUlrs) as! [Int]
        self.log.info("randomSequenceIndexUrls = \(randomSequenceIndexUrls)")
        self.randomUrls = [URL]()
        randomSequenceIndexUrls.forEach {
            self.randomUrls.append(self.urls[$0])
        }
        self.currentIndexUrl = index
        AudioPlayerManager.shared.play(urls: urls, at: index)
    }

    func forward() {
        self.log.info("currentIndexUrl = \(self.currentIndexUrl)")
        self.currentIndexUrl += 1
        if self.currentIndexUrl >= self.urls.count {
            self.currentIndexUrl = 0
        }
        if self.isChangeSequence || self.currentIndexUrl == 0 {
            self.isChangeSequence = false
            if self.isCasualNextPlay {
                AudioPlayerManager.shared.play(urls: self.randomUrls, at: self.currentIndexUrl)
            } else {
                AudioPlayerManager.shared.play(urls: self.urls, at: self.currentIndexUrl)
            }
        } else {
            AudioPlayerManager.shared.forward()
        }
    }
}

extension PlayerViewController {
    func doneAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didPressPlayRemote(_ notification: Notification) {
        self.log.info(notification)
        if self.airpodsConnected {
            self.playPauseButton.sendActions(for: .touchUpInside)
        } else {
            AudioPlayerManager.shared.play()
        }
    }
    func didPressPauseRemote(_ notification: Notification) {
        self.log.info(notification)
        if self.airpodsConnected {
            self.playPauseButton.sendActions(for: .touchUpInside)
        } else {
            AudioPlayerManager.shared.pause()
        }
    }
    
    func volumeValueChanged(_ notification: Notification) {
        self.log.info(notification)
        if let volumeValue = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
            self.volumeSlider.value = volumeValue
        }
    }
    
    func didChangeVolumeSliderValue(_ sender: UISlider) {
        (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(self.volumeSlider.value, animated: false)
    }

    func sameNextPlayOnOffTouchUpInside(_ sender: UIButton) {
        if self.isSameNextPlay {
            self.isSameNextPlay = false
            self.sameNextPlayOnOffButton.setImage(self.sameNextPlayOffImage, for: .normal)
        } else {
            self.isSameNextPlay = true
            self.sameNextPlayOnOffButton.setImage(self.sameNextPlayOnImage, for: .normal)
        }
    }
    
    func didChangeMuteStateValue(_ sender: UIButton) {
        if self.isMute {
            self.isMute = false
            self.muteOnOffButton.setImage(self.muteOffImage, for: .normal)
        } else {
            self.isMute = true
            self.muteOnOffButton.setImage(self.muteOnImage, for: .normal)
        }
        AudioPlayerManager.shared.setMute(self.isMute)
        /*
         open func setMute(_ muted: Bool) {
            self.player?.isMuted = muted
         }
        */
    }
}

// MARK: - IBActions

extension PlayerViewController {
    
    @IBAction func casualNextPlayOnOffTouchUpInside(_ sender: UIButton) {
        self.isChangeSequence = true
        if self.isCasualNextPlay {
            self.isCasualNextPlay = false
            self.casualNextPlayOnOffButton.setImage(self.casualNextPlayOffImage, for: .normal)
        } else {
            self.isCasualNextPlay = true
            self.casualNextPlayOnOffButton.setImage(self.casualNextPlayOnImage, for: .normal)
        }
        DefaultsKeys.setCasualNextPlay(self.isCasualNextPlay)
    }
    
    @IBAction func didPressRewindButton(_ sender: AnyObject) {
        if (AudioPlayerManager.shared.currentTrack?.currentTimeInSeconds())! <= Float(1) || self.isCasualNextPlay == false {
            AudioPlayerManager.shared.rewind()
        } else {
            self.forward()
        }
    }
    
    @IBAction func didPressStopButton(_ sender: AnyObject) {
        AudioPlayerManager.shared.stop()
    }
    
    @IBAction func didPressPlayPauseButton(_ sender: AnyObject) {
        if self.airpodsConnected {
            self.didPressForwardButton(sender)
        } else {
            AudioPlayerManager.shared.togglePlayPause()
        }
    }
    
    @IBAction func didPressForwardButton(_ sender: AnyObject) {
        self.forward()
    }
    
    @IBAction func didChangeTimeSliderValue(_ sender: Any) {
        guard let _newProgress = self.timeSlider?.value else {
            return
        }
        AudioPlayerManager.shared.seek(toProgress: _newProgress)
    }
}
