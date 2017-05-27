//
//  EPContactCell.swift
//  EPContacts
//
//  Created by Prabaharan Elangovan on 13/10/15.
//  Copyright © 2015 Prabaharan Elangovan. All rights reserved.
//

import UIKit

class EPContactCell: UITableViewCell {

    @IBOutlet weak var contactTextLabel: UILabel!
    @IBOutlet weak var contactDetailTextLabel: UILabel!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactInitialLabel: UILabel!
    @IBOutlet weak var contactContainerView: UIView!
    
    var contact: User?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        selectionStyle = UITableViewCellSelectionStyle.none
        contactContainerView.layer.masksToBounds = true
        contactContainerView.layer.cornerRadius = contactContainerView.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateInitialsColorForIndexPath(_ indexpath: IndexPath) {
        //Applies color to Initial Label
        let colorArray = [EPGlobalConstants.Colors.amethystColor,EPGlobalConstants.Colors.asbestosColor,EPGlobalConstants.Colors.emeraldColor,EPGlobalConstants.Colors.peterRiverColor,EPGlobalConstants.Colors.pomegranateColor,EPGlobalConstants.Colors.pumpkinColor,EPGlobalConstants.Colors.sunflowerColor]
        let randomValue = (indexpath.row + indexpath.section) % colorArray.count
        contactInitialLabel.backgroundColor = colorArray[randomValue]
    }
 
    func updateContactsinUI(_ contact: User, indexPath: IndexPath, subtitleType: SubtitleCellValue) {
        self.contact = contact
        //Update all UI in the cell here
        self.contactTextLabel?.text = contact.userFullName
        updateSubtitleBasedonType(subtitleType, contact: contact)
        if contact.avatar != "" {
            self.contactImageView.af_setImage(withURL: URL(string: contact.avatar)!)
            self.contactImageView.isHidden = false
            self.contactInitialLabel.isHidden = true
        } else {
            self.contactInitialLabel.text = userInitials(user: contact)
            updateInitialsColorForIndexPath(indexPath)
            self.contactImageView.isHidden = true
            self.contactInitialLabel.isHidden = false
        }
    }
    func userInitials(user: User)->String{
        if user.userFullName != ""{
            var initials = String()
            
            if let firstNameFirstChar = user.userFullName.components(separatedBy:.whitespaces)[0].characters.first {
                initials.append(firstNameFirstChar)
            }
            
            if let lastNameFirstChar = user.userFullName.components(separatedBy:.whitespaces)[1].characters.first {
                initials.append(lastNameFirstChar)
            }
            return initials
        }
        return ""
    }
    func updateSubtitleBasedonType(_ subtitleType: SubtitleCellValue , contact: User) {
        
        switch subtitleType {
            
        case SubtitleCellValue.phoneNumber:
            self.contactDetailTextLabel.text = "\(contact.userPhone)"
        case SubtitleCellValue.email:
            self.contactDetailTextLabel.text = "\(contact.userEmail)"
        case SubtitleCellValue.birthday:
            self.contactDetailTextLabel.text = contact.userBirthday
        case SubtitleCellValue.userName:
            self.contactDetailTextLabel.text = "@\(contact.userName)"
        }
    }
}
