//
//  DGFeedCell.swift
//  TemplateLayoutDemo
//
//  Created by zhaodg on 11/26/15.
//  Copyright © 2015 zhaodg. All rights reserved.
//

import UIKit

class DGFeedCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var lblComments: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.bounds = UIScreen.main.bounds
    }

    func loadData(_ item: DGFeedItem) {
        self.titleLabel.text = item.title
        if item.imageURL.characters.count > 0 {
            let size = contentImageView.frame.size
            
            contentImageView.af_setImage(
                withURL: URL(string: item.imageURL)!,
                placeholderImage: UIImage.init(named: "PlaceholderImage"),
                filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: 0.0),
                imageTransition: .crossDissolve(0.2)
            )
        }
        if item.profile_picture.characters.count > 0 {
            let size = avatarImageView.frame.size
            
            avatarImageView.af_setImage(
                withURL: URL(string: item.profile_picture)!,
                placeholderImage: UIImage.init(named: "avatar"),
                filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: 30.0),
                imageTransition: .crossDissolve(0.2)
            )
        }

        self.userNameLabel.text = item.userName
        
        if item.time < 60 {
            self.timeLabel.text = String(format: "%ds ago", item.time)
        }else if item.time < 3600 {
            self.timeLabel.text = String(format: "%dm ago", item.time / 60)
        }else if item.time < 86400 {
            self.timeLabel.text = String(format: "%dh ago", item.time / 3600)
        }else{
            self.timeLabel.text = String(format: "%dd ago", item.time / 86400)
        }
        self.lblLikes.text = String(format: "%d", item.likes_count)
        self.lblComments.text = String(format: "%d",item.comment_count)
    }
    @IBAction func likeAction(_ sender: Any) {
    }
    @IBAction func commentAction(_ sender: Any) {
    }
    @IBAction func reportAction(_ sender: Any) {
    }
    

    // If you are not using auto layout, override this method, enable it by setting
    // "fd_enforceFrameLayout" to YES.
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        var height: CGFloat = 0
//        height += self.contentImageView.sizeThatFits(size).height
//        height += self.userNameLabel.sizeThatFits(size).height
//        height += self.timeLabel.sizeThatFits(size).height
//        return CGSize(width: size.width, height: height)
//    }

}
