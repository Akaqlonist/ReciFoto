//
//  MinimumCommentTableViewCell.swift
//  ReciFoto
//
//  Created by Colin Taylor on 2/18/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class MinimumCommentTableViewCell: UITableViewCell {
    
    private static let AvatarPlaceholder = UIImage(named: "avatar_placeholder")
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
                placeholderImage: MinimumCommentTableViewCell.AvatarPlaceholder,
                filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: 0.0),
                imageTransition: .crossDissolve(0.2)
            )
        }
        authorLabel.text = "\(comment.author.userName)"
        commentLabel.text = comment.text
        commentLabel.sizeToFit()
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
        avatarImage.layer.cornerRadius = CGFloat(MinimumCommentTableViewCell.AvatarSize / 2)
    }
    
    private func layoutUI() {
        ([authorLabel, commentLabel, timeLabel, avatarImage] as [UIView]).forEach { (view) in
            addSubview(view)
        }
        
        let margin = 10
        let commonWidth = 60
        
        avatarImage.snp.makeConstraints { (make) in
            make.leading.top.equalTo(margin)
            make.width.height.equalTo(MinimumCommentTableViewCell.AvatarSize)
        }
        
        authorLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(avatarImage.snp.trailing).offset(margin)
            make.top.equalTo(avatarImage.snp.top)
            make.bottom.equalTo(timeLabel.snp.top)
            make.width.equalTo(commonWidth)
            //            make.centerY.equalTo(avatarImage)
//            make.trailing.equalTo(self).inset(margin)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(avatarImage.snp.trailing).offset(margin)
            make.bottom.equalTo(avatarImage.snp.bottom)
            make.width.equalTo(commonWidth)
            //            make.centerY.equalTo(avatarImage)
//            make.trailing.equalTo(self).inset(margin)
        }
        
        commentLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(self)
            make.leading.equalTo(timeLabel.snp.trailing).offset(margin)
            make.trailing.equalTo(self).inset(margin)
            make.centerY.equalTo(avatarImage.snp.centerY)
//            make.bottom.equalTo(self)
        }
        
        
    }
}
