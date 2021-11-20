//
//  ConversationTableViewCell.swift
//  InteractiveChatApp
//
//  Created by Yongqi Chao on 11/15/21.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {

//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 80,
                                     height: 80)
        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height - 20) / 2)
        userMessageLabel.frame = CGRect(x: userImageView.right + 10,
                                        y: userNameLabel.bottom + 10,
                                        width: contentView.width - 20 - userImageView.width,
                                        height: (contentView.height - 20) / 2)
    }
    
    // views
    private let userImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        // number of lines to render , 0 is no limitation
        label.numberOfLines = 0 // 2
        return label
    }()

    // data
    static let identifier = "ConversationTableViewCell"
    
    // funcs
    public func configure(with model : LatestMessage) {
        self.userMessageLabel.text = model.content
        self.userNameLabel.text = model.recipient_name
        
        let photoUrl = "images/\(model.recipient_email)_profile_picture.png"
//        StorageManeger.shared.downloadURL(for: photoUrl,
//                                             completion: { [weak self] result in
//            switch result {
//            case .failure(let error) :
//                print("Failed to download image for chat: \(error)")
//            case .success(let url) :
//                DispatchQueue.main.async {
//                    self?.userImageView.sd_setImage(with: url, completed: nil)
//                }
//            }
//        })
    }

}
