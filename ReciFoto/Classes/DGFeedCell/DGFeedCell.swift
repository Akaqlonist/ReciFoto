//
//  DGFeedCell.swift
//  TemplateLayoutDemo
//
//  Created by zhaodg on 11/26/15.
//  Copyright © 2015 zhaodg. All rights reserved.
//

import UIKit

protocol DGFeedCellDelegate {
    func didLikeWithItem(item : Recipe)
    func didMoreWithItem(item : Recipe, sender : UIButton)
    func didCommentWithItem(item : Recipe)
    func didProfileWithItem(item : Recipe)
    func didDetailWithItem(item : Recipe)
    func didLinkClickedWithItem(item: Recipe, url: URL, sender: UIView)
}
class DGFeedCell: UITableViewCell {

    @IBOutlet weak var titleLabel: LinkLabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    var recipeItem : Recipe?
    var delegate : DGFeedCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.bounds = UIScreen.main.bounds
    }

    func loadData(_ item: Recipe) {
        recipeItem = item
//        self.titleLabel.text = item.title
        //set Attributed String
        let text = item.title
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = self.titleLabel.font.pointSize * 1.5
        paragraphStyle.maximumLineHeight = self.titleLabel.font.pointSize * 1.5
        
        self.titleLabel.attributedText = NSAttributedString(string: text, attributes: [
            NSParagraphStyleAttributeName: paragraphStyle
            ])
        
        if item.recipe_website.characters.count > 0{
            print(item.recipe_website)
            print(URL(string: item.recipe_website) ?? "default url")
            _ = self.titleLabel.addLink(url: URL(string: item.recipe_website)!, range: NSMakeRange(0, text.characters.count), linkAttribute: [
                NSFontAttributeName : UIFont.italicSystemFont(ofSize: self.titleLabel.font.pointSize),
                NSForegroundColorAttributeName: UIColor.white,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject
                ], selection: { (url) in
                    self.delegate?.didLinkClickedWithItem(item: item, url: url,sender: self.titleLabel)
            })
        }

        if item.imageURL.characters.count > 0 {
//            let size = contentImageView.frame.size
            contentImageView.af_setImage(withURL: URL(string: item.imageURL)!)
//            contentImageView.af_setImage(
//                withURL: URL(string: item.imageURL)!,
//                placeholderImage: UIImage.init(named: "PlaceholderImage"),
//                filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: 0.0),
//                imageTransition: .crossDissolve(0.2)
//            )
        }
        if item.user.avatar.characters.count > 0 {
            let size = avatarImageView.frame.size
            
            avatarImageView.af_setImage(
                withURL: URL(string: item.user.avatar)!,
                placeholderImage: UIImage.init(named: "avatar"),
                filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: 30.0),
                imageTransition: .crossDissolve(0.2)
            )
        }else{
            avatarImageView.image = UIImage(named: "avatar")
        }

        self.userNameLabel.text = item.user.userName
        
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
        self.lblLikes.text = String(format: "%d", (self.recipeItem?.likes_count)!+1)
        self.delegate?.didLikeWithItem(item: self.recipeItem!)
    }
    @IBAction func commentAction(_ sender: Any) {
        self.delegate?.didCommentWithItem(item: self.recipeItem!)
    }
    @IBAction func moreAction(_ sender: Any) {
        self.delegate?.didMoreWithItem(item: self.recipeItem!, sender : sender as! UIButton)
    }
    @IBAction func profileAction(_ sender: Any) {
        self.delegate?.didProfileWithItem(item: self.recipeItem!)
    }
    @IBAction func detailAction(_ sender: Any) {
        self.delegate?.didDetailWithItem(item: self.recipeItem!)
    }
}
