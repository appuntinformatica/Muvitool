import UIKit
import XCGLogger

class PlaylistSelectionViewController: UITableViewController {
    let log = XCGLogger.default
    
    var filename: String!
    var dataArrayCompleted = Array<Playlist>()

    init() {
        super.init(style: .plain)
        self.title = Strings.Playlist
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PlaylistSelectionViewController.cancelAction(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(PlaylistSelectionViewController.saveAction(_:)))
        
        self.tableView.allowsMultipleSelection = true
        
        self.dataArrayCompleted = PlaylistDataHelper.findAll()
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        self.tableView.indexPathsForSelectedRows?.forEach {
            self.log.info(" --> \(self.dataArrayCompleted[$0.row].description) ")
            let playlistId = self.dataArrayCompleted[$0.row].id
            
            let count = PlaylistItemDataHelper.getCount(byPlaylistId: playlistId)
            
            let id = PlaylistItemDataHelper.insert(PlaylistItem(id: 0, playlistId: playlistId, filename: self.filename, displayOrder: count + 1))
            self.log.info("PlaylistItemDataHelper.insert \(id)")
        }        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArrayCompleted.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "PlaylistCell")
        
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.selectionStyle = .none
        
        let item = self.dataArrayCompleted[indexPath.row]
        
        cell.textLabel?.text = item.description
        
        return cell
    }
}
