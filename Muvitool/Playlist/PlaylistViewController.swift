import UIKit
import XCGLogger

class PlaylistViewController: UITableViewController {
    let log = XCGLogger.default
    
    var searchController: UISearchController!
    var dataArrayCompleted  = Array<Playlist>()
    var dataArrayFiltered  = Array<Playlist>()
    
    init() {
        super.init(style: .plain)
        self.title = Strings.Playlist
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

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(PlaylistViewController.showPlaylistEditor(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(PlaylistViewController.editAction(_:)))
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    func selectItem(row: Int) -> Playlist {
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            return self.dataArrayFiltered[row]
        } else {
            return self.dataArrayCompleted[row]
        }
    }
    
    func reloadData() {
        self.dataArrayCompleted = PlaylistDataHelper.findAll()
        self.dataArrayFiltered.removeAll()
        if self.searchController != nil && 	self.searchController.isActive && self.searchController.searchBar.text != "" {
            let searchText = searchController.searchBar.text?.lowercased()
            self.dataArrayFiltered = self.dataArrayCompleted.filter {
                return $0.description.lowercased().contains(searchText!)
            }
        }
        self.tableView.reloadData()
    }
}

extension PlaylistViewController {
    @IBAction func showPlaylistEditor(_ sender: UIBarButtonItem) {
        let vc = PlaylistItemViewController()
        vc.playlist = Playlist(id: 0, description: "", displayOrder: self.dataArrayCompleted.count + 1)
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        self.searchController.isActive = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PlaylistViewController.doneAction(_:)))
        self.tableView.setEditing(true, animated: true)
        
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(PlaylistViewController.showPlaylistEditor(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(PlaylistViewController.editAction(_:)))        
        self.tableView.setEditing(false, animated: true)
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }
    
    @IBAction func playPlaylist(_ sender: UIButton) {
        let item = self.dataArrayCompleted[sender.tag]
        self.log.info(item.description)
        
        var urls        : [URL] = []
        let playlistItems = PlaylistItemDataHelper.findAll(byPlaylistId: item.id)
        playlistItems.forEach {
            urls.append(URL(fileURLWithPath: "\(AudioFileManager.musicFilePath)/\($0.filename)"))
        }
        self.present(UINavigationController(rootViewController: PlayerViewController.shared), animated: true, completion: {
            PlayerViewController.shared.play(urls: urls, at: 0)
        })
    }
}

extension PlaylistViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PlaylistCell.Height
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
        let cell = PlaylistCell(style: .default, reuseIdentifier: PlaylistCell.Identifier)
        
        let item = self.selectItem(row: indexPath.row)
        
        cell.playlistNameLabel.text = item.description
        
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(PlaylistViewController.playPlaylist(_:)), for: .touchUpInside)
          
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = self.dataArrayCompleted.remove(at: sourceIndexPath.row)
        self.dataArrayCompleted.insert(itemToMove, at: destinationIndexPath.row)
        PlaylistDataHelper.reorder(self.dataArrayCompleted)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.log.info("")
            let item = self.selectItem(row: indexPath.row)
            let nd = PlaylistDataHelper.delete(item)
            self.log.info("PlaylistDataHelper.delete: \(nd)")
            self.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.selectItem(row: indexPath.row)
        let vc = PlaylistItemViewController()
        vc.playlist = item
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}

extension PlaylistViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.reloadData()
    }
}
extension PlaylistViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.reloadData()
    }
}
extension PlaylistViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
}
