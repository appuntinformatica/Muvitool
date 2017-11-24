import UIKit
import AVKit
import AVFoundation
import AudioPlayerManager
import XCGLogger

class MusicLibraryViewController: UITableViewController {
    let log = XCGLogger.default

    var searchController: UISearchController!
    
    var dataArrayCompleted = Array<AudioFileModel>()
    var dataArrayFiltered  = Array<AudioFileModel>()
    
    init() {
        super.init(style: .plain)
        self.title = Strings.Music
        self.dataArrayCompleted = AudioFileManager.shared.data
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()                

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MusicLibraryViewController.addMusicAction(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ipod"), style: .plain, target: self, action: #selector(MusicLibraryViewController.showPlayerAction(_:)))

        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.definesPresentationContext = true
        
        self.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    }

    func reloadData() {
        self.dataArrayCompleted.removeAll()
        self.dataArrayFiltered.removeAll()
        self.dataArrayCompleted = AudioFileManager.shared.data
        
        if self.searchController != nil && 	self.searchController.isActive && self.searchController.searchBar.text != "" {
            let searchText = searchController.searchBar.text?.lowercased()
            self.dataArrayFiltered = self.dataArrayCompleted.filter {
                return $0.filename.lowercased().contains(searchText!)
            }
        }
        self.tableView.reloadData()
    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MusicLibraryCell.Height
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            return self.dataArrayFiltered.count
        } else {
            return self.dataArrayCompleted.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MusicLibraryCell(style: .default, reuseIdentifier: MusicLibraryCell.Identifier)
        
        var item: AudioFileModel!
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            item = self.dataArrayFiltered[indexPath.row]
        } else {
            item = self.dataArrayCompleted[indexPath.row]
        }
        
        cell.filenameLabel.text = item.filename
        cell.fileinfoLabel.text = "\(item.title) - \(item.artist)"
        cell.previewImageView.image = item.artwork
        cell.playButton.accessibilityElements = [Any]()
        cell.playButton.accessibilityElements?.append(item)
        cell.playButton.addTarget(self, action: #selector(MusicLibraryViewController.playTouchUpInside(_:)), for: .touchUpInside)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showSubmenu(indexPath.row)
    }
    
    @IBAction func playTouchUpInside(_ sender: UIButton) {
        if let am = sender.accessibilityElements?[0] as? AudioFileModel {
            self.play(am, false)
        }
    }
    
    @IBAction func showPlayerAction(_ sender: UIBarButtonItem) {
        self.present(UINavigationController(rootViewController: PlayerViewController.shared), animated: true, completion: nil)
    }
    
    @IBAction func addMusicAction(_ sender: UIBarButtonItem) {
        let vc = AddMusicViewController()
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}

extension MusicLibraryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.reloadData()
    }
}
extension MusicLibraryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.reloadData()
    }
}
extension MusicLibraryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
}
