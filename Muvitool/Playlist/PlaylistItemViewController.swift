import UIKit
import XCGLogger
import SnapKit

class PlaylistItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let log = XCGLogger.default
    
    var playlist: Playlist!
    var dataArrayCompleted = Array<PlaylistItem>()
    var dataArrayRemoved   = Array<PlaylistItem>()
    
    var playlistText:       UITextField!
    var tableView:          UITableView!
    var deleteButton:       UIButton!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = Strings.Playlist
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isNewPlaylist: Bool {
        get {
            return ( self.playlist.id == 0 )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PlaylistItemViewController.cancelAction(_:)))

        if self.isNewPlaylist {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PlaylistItemViewController.doneAction(_:)))
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(PlaylistItemViewController.editAction(_:)))
        }

        self.playlistText = UITextField()
        if self.isNewPlaylist {
            self.playlistText.isEnabled = true
            self.playlistText.addTarget(self, action: #selector(PlaylistItemViewController.playlistTextEditingChanged(_:)), for: .editingChanged)
        } else {
            self.playlistText.isEnabled = false
        }
        self.playlistText.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0)
        self.playlistText.placeholder = Strings.PlaylistTitle
        self.playlistText.text = self.playlist.description
        self.view.addSubview(self.playlistText)
        self.playlistText.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top).offset(70)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
            $0.height.equalTo(50)
        }

        self.tableView = UITableView()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.playlistText.snp.bottom).offset(10)
            $0.left.equalTo(self.view.snp.left)
            $0.right.equalTo(self.view.snp.right)
            $0.bottom.equalTo(self.view.snp.bottom).offset(-75)
        }
        
        if !self.isNewPlaylist {
            self.deleteButton = UIButton(type: .roundedRect)
            self.deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            self.deleteButton.tintColor = .white
            self.deleteButton.backgroundColor = .red
            self.deleteButton.layer.cornerRadius = 10
            self.deleteButton.addTarget(self, action: #selector(PlaylistItemViewController.deletePlaylistTouchUpInside(_:)), for: .touchUpInside)
            self.deleteButton.setTitle(Strings.DeletePlaylist, for: .normal)
            self.view.addSubview(self.deleteButton)
            self.deleteButton.snp.makeConstraints {
                $0.top.equalTo(self.tableView.snp.bottom).offset(20)
                $0.centerX.equalTo(self.view.snp.centerX)
                $0.height.equalTo(50)
                $0.width.equalTo(200)
            }
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    func reloadData() {
        self.dataArrayCompleted = PlaylistItemDataHelper.findAll(byPlaylistId: self.playlist.id)
        self.tableView.reloadData()
    }
    
    @IBAction func playTouchUpInside(_ sender: UIButton) {
        if let am = sender.accessibilityElements?[0] as? AudioFileModel {
            self.play(am, false)
        }
    }
    
    @IBAction func deletePlaylistTouchUpInside(_ sender: UIButton) {
        let ac = UIAlertController(title: Strings.AreYouSure, message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: Strings.Yes, style: .default, handler: { (alertAction: UIAlertAction) in
            var result = PlaylistDataHelper.delete(self.playlist)
            self.log.info("PlaylistDataHelper.delete: \(result)")
            result = PlaylistItemDataHelper.delete(withPlaylistId: self.playlist.id)
            self.log.info("PlaylistDataHelper.delete: \(result)")
            self.dismiss(animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: Strings.No, style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }

    @IBAction func playlistTextEditingChanged(_ sender: UITextField) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PlaylistItemViewController.doneAction(_:)))
        self.tableView.setEditing(true, animated: true)
        self.playlistText.isEnabled = true
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        if self.playlistText.text == "" {
            return
        }
        self.playlist.description = self.playlistText.text!
        if self.isNewPlaylist {
            let id = PlaylistDataHelper.insert(self.playlist)
            self.log.info("PlaylistDataHelper.insert id = \(id)")
        } else {
            let result = PlaylistDataHelper.update(self.playlist)
            self.log.info("PlaylistDataHelper.update: \(result)")
            self.dataArrayRemoved.forEach {
                let nd = PlaylistItemDataHelper.delete($0)
                self.log.info("PlaylistItemDataHelper.delete(\($0.id)): \(nd)")
            }
            PlaylistItemDataHelper.reorder(self.playlist.id, self.dataArrayCompleted)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension PlaylistItemViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MusicLibraryCell.Height
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArrayCompleted.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MusicLibraryCell(style: .default, reuseIdentifier: MusicLibraryCell.Identifier)

        let item = self.dataArrayCompleted[indexPath.row]
        let audioFileModel = AudioFileManager.shared.data.first(where: {
            return $0.filename == item.filename
        })
        cell.filenameLabel.text = item.filename
        cell.previewImageView.image = audioFileModel?.artwork
        cell.playButton.accessibilityElements = [Any]()
        cell.playButton.accessibilityElements?.append(audioFileModel)
        cell.playButton.addTarget(self, action: #selector(PlaylistItemViewController.playTouchUpInside(_:)), for: .touchUpInside)
        
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            let playlistItemRemoved = self.dataArrayCompleted.remove(at: indexPath.row)
            self.dataArrayRemoved.append(playlistItemRemoved)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        let itemToMove = self.dataArrayCompleted[sourceIndexPath.row]
        self.dataArrayCompleted.remove(at: sourceIndexPath.row)
        self.dataArrayCompleted.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    func play(_ am: AudioFileModel, _ showPlayer: Bool = true) {
        var urls        : [URL] = []
        var indexSelected = -1
        
        for (index, item) in self.dataArrayCompleted.enumerated() {
            urls.append(URL(fileURLWithPath: "\(AudioFileManager.musicFilePath)/\(item.filename)"))
            if item.filename == am.filename {
                indexSelected = index
            }
        }
        if showPlayer {
            self.present(UINavigationController(rootViewController: PlayerViewController.shared), animated: true, completion: {
                PlayerViewController.shared.play(urls: urls, at: indexSelected)
            })
        } else {
            PlayerViewController.shared.play(urls: urls, at: indexSelected)
        }
    }

}
