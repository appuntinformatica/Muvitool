import UIKit
import SnapKit

class MusicLibraryCell: UITableViewCell {
    static let Identifier = "MusicLibraryCell"
    static let Height = CGFloat(60)
    
    var previewImageView: UIImageView!
    var filenameLabel:    UILabel!
    var fileinfoLabel:    UILabel!
    var playButton:       UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let frame = CGRect(x: 0, y: 0, width: MusicLibraryCell.Height - 10, height: MusicLibraryCell.Height - 10)
        let overlay = UIView(frame: frame)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        self.previewImageView = UIImageView(frame: frame)
        self.previewImageView.image = UIImage(named: "no_video")
        overlay.addSubview(self.previewImageView)
        self.contentView.addSubview(overlay)
               
        overlay.snp.makeConstraints {
            $0.top.equalTo(self.contentView.snp.top).offset(5)
            $0.left.equalTo(self.contentView.snp.left).offset(5)
            $0.right.equalTo(self.contentView.snp.right)
            $0.centerY.equalTo(self.contentView.snp.centerY).offset(0)
        }
        
        self.playButton = UIButton()
        self.playButton.setImage(UIImage(named: "play"), for: .normal)
        
        self.contentView.addSubview(self.playButton)
        self.playButton.snp.makeConstraints {
            $0.right.equalTo(self.contentView.snp.right).offset(-5)
            $0.centerY.equalTo(self.contentView.snp.centerY)
            $0.size.equalTo(60)
        }
        
        self.filenameLabel = UILabel()
        self.contentView.addSubview(self.filenameLabel)
        self.filenameLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.contentView.snp.centerY).offset(-5)
            $0.left.equalTo(self.previewImageView.snp.right).offset(5)
            $0.right.equalTo(self.playButton.snp.left).offset(5)
        }

        self.fileinfoLabel = UILabel()
        self.fileinfoLabel.preferredMaxLayoutWidth = 50
        self.fileinfoLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightRegular)
        self.contentView.addSubview(self.fileinfoLabel)
        
        self.fileinfoLabel.snp.makeConstraints {
            $0.top.equalTo(self.contentView.snp.centerY).offset(5)
            $0.left.equalTo(self.previewImageView.snp.right).offset(5)
            $0.right.equalTo(self.playButton.snp.left).offset(5)
        }
    }
}
