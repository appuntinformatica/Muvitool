import UIKit

extension MusicLibraryViewController {
    func selectAudioModel(_ row: Int) -> AudioFileModel {
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            return self.dataArrayFiltered[row]
        } else {
            return self.dataArrayCompleted[row]
        }
    }
    
    func play(_ am: AudioFileModel, _ showPlayer: Bool = true) {
        var urls        : [URL] = []
        var indexSelected = -1
        
        for (index, item) in self.dataArrayCompleted.enumerated() {
            urls.append(URL(fileURLWithPath: "\(item.folderPath)/\(item.filename)"))
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
    
    func showSubmenu(_ row: Int) {
        self.log.info("row = \(row)")
        let am = self.selectAudioModel(row)
        let playAction = UIAlertAction(title: Strings.Play, style: .default, handler: { (alertAction: UIAlertAction) in
            self.play(am)
        })
        
        let deleteAction = UIAlertAction(title: Strings.Delete, style: .default, handler: { (alertAction: UIAlertAction) in
            let vc = UIAlertController(title: Strings.AreYouSure, message: "", preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: Strings.Yes, style: .default, handler: { (alertAction: UIAlertAction) in
                let count = PlaylistItemDataHelper.getCount(byFilename: am.filename)
                self.log.info("\(am.filename) --> \(count)")
                if count > 0 {
                    let ac = UIAlertController(title: Strings.FilenameAlreadyPlaylistAssociated, message: "", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: Strings.Yes, style: .default, handler: { (alertAction: UIAlertAction) in
                        AudioFileManager.shared.delete(am)
                        self.reloadData()
                    }))
                    ac.addAction(UIAlertAction(title: Strings.No, style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                } else {
                    AudioFileManager.shared.delete(am)
                    self.reloadData()
                }
            }))
            vc.addAction(UIAlertAction(title: Strings.No, style: .default, handler: nil))
            self.present(vc, animated: true, completion: nil)
        })
        
        let addToPlaylistAction = UIAlertAction(title: Strings.AddToPlaylist, style: .default, handler: { (alertAction: UIAlertAction) in
            let vc = PlaylistSelectionViewController()
            vc.filename = am.filename
            self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: Strings.Cancel, style: .default, handler: nil)
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(playAction)
        vc.addAction(deleteAction)
        vc.addAction(addToPlaylistAction)
        vc.addAction(cancelAction)
        vc.popoverPresentationController?.sourceView = self.view
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        vc.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)

        self.present(vc, animated: true, completion: {
            if (vc.view.superview?.subviews.count)! > 0 {
                vc.view.superview?.subviews[0].isUserInteractionEnabled = true
                vc.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MusicLibraryViewController.alertControllerBackgroundTapped(_:))))
            }
        })
    }
    
    @IBAction func alertControllerBackgroundTapped(_ sender: UITapGestureRecognizer) {
        self.log.info(sender)
        self.dismiss(animated: true, completion: nil)
    }
}
