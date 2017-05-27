//
//  User.swift
//  NewsFeed
//
//  Created by Alex Manzella on 08/07/16.
//  Copyright © 2016 devlucky. All rights reserved.
//

import Foundation

struct User {
    
    var id: String
    var userName: String
    var avatar: String
    var userEmail : String
    var userBio : String
    var userPhone : String
    var userFullName : String
    var userBirthday : String
    
    init(){
        id = ""
        userName = ""
        avatar = ""
        userEmail = ""
        userBio = ""
        userPhone = ""
        userFullName = ""
        userBirthday = ""
    }
    init(id: String) {
        self.id = id
        userName = ""
        avatar = ""
        userEmail = ""
        userBio = ""
        userPhone = ""
        userFullName = ""
        userBirthday = ""
    }
    init(id: String, username: String, avatar : String?){
        self.id = id
        self.userName = username
        if (avatar != nil) {
            self.avatar = avatar!
        }else{
            self.avatar = ""
        }
        userEmail = ""
        userBio = ""
        userPhone = ""
        userFullName = ""
        userBirthday = ""
    }
    init (dict: NSDictionary){
        id = dict[Constants.ID_KEY] as! String
        userName = dict[Constants.USER_NAME_KEY] as! String
        userEmail = dict[Constants.EMAIL_KEY] as! String
        if let avatar_link = dict[Constants.PROFILE_PICTURE_KEY] as? String {
            avatar = avatar_link.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        }else{
            if let pic_link = dict[Constants.PROFILE_PIC_KEY] as? String{
                avatar = pic_link.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            }else{
                avatar = ""
            }
        }
        if let profile_bio_link = dict[Constants.PROFILE_BIO_KEY] as? String{
            userBio = profile_bio_link
        }else{
            if let bio_link = dict[Constants.BIO_KEY] as? String{
                userBio = bio_link
            }else{
                userBio = ""
            }
        }
        if let phone_link = dict[Constants.PHONE_NUM_KEY] as? String{
            userPhone = phone_link
        }else{
            userPhone = ""
        }
        if let birthday_link = dict[Constants.USER_BIRTHDAY_KEY] as? String{
            userBirthday = birthday_link
        }else{
            userBirthday = Utility.sharedInstance.dateToString(date: Date())
        }
        userFullName = dict[Constants.USER_FULL_NAME_KEY] as! String
    }
}
