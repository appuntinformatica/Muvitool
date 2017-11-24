import UIKit
import SnapKit

class PlaylistCell: UITableViewCell {
    
    static let Identifier = "PlaylistCell"
    static let Height = CGFloat(60)
    
    var playImageView:     UIImageView!
    var playButton:        UIButton!
    var playlistNameLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.playButton = UIButton()
        self.playButton.setImage(UIImage(named: "play"), for: .normal)
        self.contentView.addSubview(self.playButton)
        self.playButton.snp.makeConstraints {
            $0.left.equalTo(self.contentView.snp.left).offset(5)
            $0.centerY.equalTo(self.contentView.snp.centerY)
            $0.size.equalTo(60)
        }
        
        self.playlistNameLabel = UILabel()
        self.contentView.addSubview(self.playlistNameLabel)
        self.playlistNameLabel.snp.makeConstraints {
            $0.left.equalTo(self.playButton.snp.right).offset(5)
            $0.centerY.equalTo(self.contentView.snp.centerY)
        }
    }
}
