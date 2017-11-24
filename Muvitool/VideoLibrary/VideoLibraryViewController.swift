import UIKit
import AVKit
import AVFoundation
import XCGLogger

/*
 https://github.com/kewlbear/FFmpeg-iOS-build-script
 */
class VideoLibraryViewController: UITableViewController {
    let log = XCGLogger.default
    let vfmShare = VideoFileManager.shared
    
    var progressIndicator:     UIActivityIndicatorView!
    
    var searchController: UISearchController!
    var videoModelCompleted = [ VideoFileModel ]()
    var videoModelFiltered  = [ VideoFileModel ]()
    
    init() {
        super.init(style: .plain)
        self.title = Strings.Video
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.definesPresentationContext = true

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(VideoLibraryViewController.addingVideoAction(_:)))        
        
        self.progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }

    @IBAction func addingVideoAction(_ sender: UIBarButtonItem) {
        let vc = AddingVideoViewController()
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return VideoLibraryCell.Height
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            return self.videoModelFiltered.count
        } else {
            return self.videoModelCompleted.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showSubmenu(row: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = VideoLibraryCell(style: .default, reuseIdentifier: VideoLibraryCell.Identifier)
        
        let vm = self.selectVideoModel(row: indexPath.row)
        cell.filenameLabel.text = vm.filename
        
        cell.fileinfoLabel.text = "\(String(format: "%.2f", calculateFileSizeInUnit(vm.filesize))) \(calculateUnit(vm.filesize)) - \(calculateDuration(vm.duration))"
        cell.previewVideoImage.image = vm.imagePreview
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(playVideoTouchUpInside), for: .touchUpInside)
        
        return cell
    }
}

extension VideoLibraryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.reloadData()
    }
}
extension VideoLibraryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.reloadData()
    }
}
extension VideoLibraryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
}

extension VideoLibraryViewController {
    func playVideoTouchUpInside(_ sender: UIButton) {
        self.playVideo(row: sender.tag)
    }
}

extension VideoLibraryViewController {
    func playVideo(row: Int) {
        log.info("row = \(row)")
        let vm = self.selectVideoModel(row: row)
        let player = AVPlayer(url: URL(fileURLWithPath: "\(vm.folderPath)/\(vm.filename)"))
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true, completion: {
            player.play()
        })
    }
    func reloadData() {
        self.videoModelCompleted = vfmShare.data
        self.videoModelFiltered.removeAll()
        if self.searchController != nil && 	self.searchController.isActive && self.searchController.searchBar.text != "" {
            let searchText = searchController.searchBar.text?.lowercased()
            self.videoModelFiltered = self.videoModelCompleted.filter {
                return $0.filename.lowercased().contains(searchText!)
            }
        }
        self.tableView.reloadData()
    }
    func selectVideoModel(row: Int) -> VideoFileModel {
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            return self.videoModelFiltered[row]
        } else {
            return self.videoModelCompleted[row]
        }
    }
    
    func calculateFileSizeInUnit(_ contentLength : Int64) -> Float {
        let dataLength : Float64 = Float64(contentLength)
        if dataLength >= (1024.0*1024.0*1024.0) {
            return Float(dataLength/(1024.0*1024.0*1024.0))
        } else if dataLength >= 1024.0*1024.0 {
            return Float(dataLength/(1024.0*1024.0))
        } else if dataLength >= 1024.0 {
            return Float(dataLength/1024.0)
        } else {
            return Float(dataLength)
        }
    }
    
    func calculateUnit(_ contentLength : Int64) -> NSString {
        if(contentLength >= (1024*1024*1024)) {
            return "GB"
        } else if contentLength >= (1024*1024) {
            return "MB"
        } else if contentLength >= 1024 {
            return "KB"
        } else {
            return "Bytes"
        }
    }
    func calculateDuration(_ duration: Double) -> String {
        let (h, m, s) = convertSecondsToHHMMSS(seconds: duration)
        
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
    func convertSecondsToHHMMSS(seconds : Double) -> (Int, Int, Int) {
        let (hr,  minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        return ( Int(hr), Int(min), Int(60 * secf) )
    }
}
