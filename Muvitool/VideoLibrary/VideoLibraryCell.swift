import UIKit

class VideoLibraryCell: UITableViewCell {
    
    static let Identifier = "VideoLibraryCell"
    static let Height = CGFloat(80)
    
    var previewVideoImage: UIImageView!
    var playButton: UIButton!
    var filenameLabel: UILabel!
    var fileinfoLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let frame = CGRect(x: 0, y: 0, width: VideoLibraryCell.Height - 10, height: VideoLibraryCell.Height - 10)
        let overlay = UIView(frame: frame)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        self.previewVideoImage = UIImageView(frame: frame)
        self.previewVideoImage.image = UIImage(named: "no_video")
        overlay.addSubview(self.previewVideoImage)
        self.addSubview(overlay)
        
        self.playButton = UIButton(frame: frame)
        self.playButton.isSelected = true
        self.playButton.setImage(UIImage(named: "play"), for: .normal)
        self.addSubview(self.playButton)
        
        overlay.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(5)
            $0.left.equalTo(self.snp.left).offset(5)
            $0.centerY.equalTo(self.snp.centerY).offset(0)
        }

        self.filenameLabel = UILabel()
        self.addSubview(self.filenameLabel)
        
        self.filenameLabel.snp.makeConstraints {
            $0.left.greaterThanOrEqualTo(self.previewVideoImage.snp.right).offset(5)
            $0.centerY.equalTo(self.snp.centerY).offset(0)
        }
        
        self.fileinfoLabel = UILabel()
        self.fileinfoLabel.preferredMaxLayoutWidth = 50
        self.fileinfoLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightRegular)
        self.addSubview(self.fileinfoLabel)
        
        self.fileinfoLabel.snp.makeConstraints {
            $0.left.greaterThanOrEqualTo(self.previewVideoImage.snp.right).offset(5)
            $0.top.greaterThanOrEqualTo(self.filenameLabel.snp.bottom).offset(5)
        }
    }
}
