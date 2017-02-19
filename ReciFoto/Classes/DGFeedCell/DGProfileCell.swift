//
//  DGProfileCell.swift
//  ReciFoto
//
//  Created by Colin Taylor on 2/7/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class DGProfileCell: UITableViewCell {
    
    @IBOutlet weak var contentImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.bounds = UIScreen.main.bounds
    }
    
    func loadData(_ item: Recipe) {
        if item.imageURL.characters.count > 0 {
            let size = contentImageView.frame.size
            
            contentImageView.af_setImage(
                withURL: URL(string: item.imageURL)!,
                placeholderImage: UIImage.init(named: "PlaceholderImage"),
                filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: 0.0),
                imageTransition: .crossDissolve(0.2)
            )
        }
    }
    
}
