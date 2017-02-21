//
//  PostTableViewCell.swift
//  NewsFeed
//
//  Created by Alex Manzella on 28/07/16.
//  Copyright © 2016 devlucky. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    private static let AvatarPlaceholder = UIImage(named: "avatar")
    private static let AvatarSize = 35
    private let authorLabel = UILabel()
    private let commentLabel = UILabel()
    private let timeLabel = UILabel()
    private let avatarImage = UIImageView()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        styleUI()
        layoutUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        avatarImage.hnk_cancelSetImage()
    }
    
    func configure(with comment: Comment) {
        if let url = URL(string: comment.author.avatar) {
            let size = CGSize(width: 35, height: 35)
            avatarImage.af_setImage(
                withURL: url,
                placeholderImage: CommentTableViewCell.AvatarPlaceholder,
                filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: 0.0),
                imageTransition: .crossDissolve(0.2)
            )
        }
        authorLabel.text = "\(comment.author.userName)"
        commentLabel.text = comment.text
        if comment.time < 60 {
            self.timeLabel.text = String(format: "%ds ago", comment.time)
        }else if comment.time < 3600 {
            self.timeLabel.text = String(format: "%dm ago", comment.time / 60)
        }else if comment.time < 86400 {
            self.timeLabel.text = String(format: "%dh ago", comment.time / 3600)
        }else{
            self.timeLabel.text = String(format: "%dd ago", comment.time / 86400)
        }
    }
    
    private func styleUI() {
        authorLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        backgroundColor = UIColor.white
        commentLabel.numberOfLines = 0
        commentLabel.lineBreakMode = .byWordWrapping
        commentLabel.textColor = UIColor.darkGray
        timeLabel.textColor = UIColor.darkGray
        timeLabel.font = UIFont.systemFont(ofSize: 12.0)
        avatarImage.clipsToBounds = true
        avatarImage.contentMode = .scaleAspectFill
        avatarImage.layer.borderColor = UIColor.lightGray.cgColor
        avatarImage.layer.borderWidth = 0.5
        avatarImage.layer.cornerRadius = CGFloat(CommentTableViewCell.AvatarSize / 2)
    }
    
    private func layoutUI() {
        ([authorLabel, commentLabel, timeLabel, avatarImage] as [UIView]).forEach { (view) in
            addSubview(view)
        }
        
        let margin = 10
        
        avatarImage.snp.makeConstraints { (make) in
            make.leading.top.equalTo(margin)
            make.width.height.equalTo(CommentTableViewCell.AvatarSize)
        }
        
        authorLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(avatarImage.snp.trailing).offset(margin)
            make.top.equalTo(avatarImage.snp.top)
            make.bottom.equalTo(timeLabel.snp.top)
//            make.centerY.equalTo(avatarImage)
            make.trailing.equalTo(self).inset(margin)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(avatarImage.snp.trailing).offset(margin)
            make.bottom.equalTo(avatarImage.snp.bottom)
//            make.centerY.equalTo(avatarImage)
            make.trailing.equalTo(self).inset(margin)
        }
        
        commentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImage.snp.bottom)
            make.leading.equalTo(avatarImage.snp.centerX)
            make.trailing.equalTo(self).inset(margin)
            make.bottom.equalTo(self).inset(margin)
        }
        

    }
}
