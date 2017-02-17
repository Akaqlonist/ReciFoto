//
//  PostTableViewCell.swift
//  NewsFeed
//
//  Created by Alex Manzella on 28/07/16.
//  Copyright © 2016 devlucky. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    private static let AvatarPlaceholder = UIImage(named: "avatar_placeholder")
    private static let AvatarSize = 35
    private let authorLabel = UILabel()
    private let commentLabel = UILabel()
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
        authorLabel.text = "\(comment.author.username)"
        commentLabel.text = comment.text
    }
    
    private func styleUI() {
        authorLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        backgroundColor = UIColor.white
        commentLabel.numberOfLines = 0
        avatarImage.clipsToBounds = true
        avatarImage.contentMode = .scaleAspectFill
        avatarImage.layer.borderColor = UIColor.lightGray.cgColor
        avatarImage.layer.borderWidth = 0.5
        avatarImage.layer.cornerRadius = CGFloat(CommentTableViewCell.AvatarSize / 2)
    }
    
    private func layoutUI() {
        ([authorLabel, commentLabel, avatarImage] as [UIView]).forEach { (view) in
            addSubview(view)
        }
        
        let margin = 10
        
        avatarImage.snp.makeConstraints { (make) in
            make.leading.top.equalTo(margin)
            make.width.height.equalTo(CommentTableViewCell.AvatarSize)
        }
        
        authorLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(avatarImage.snp.trailing).offset(margin)
            make.centerY.equalTo(avatarImage)
            make.trailing.equalTo(self).inset(margin)
        }
        
        commentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImage.snp.bottom).offset(margin)
            make.leading.equalTo(avatarImage.snp.centerX)
            make.trailing.equalTo(authorLabel)
        }
        

    }
}
