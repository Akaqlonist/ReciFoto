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
    
    init(){
        id = ""
        userName = ""
        avatar = ""
        userEmail = ""
        userBio = ""
        userPhone = ""
    }
    init(id: String) {
        self.id = id
        userName = ""
        avatar = ""
        userEmail = ""
        userBio = ""
        userPhone = ""
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
    }
    init (dict: NSDictionary){
        id = dict[Constants.ID_KEY] as! String
        userName = dict[Constants.USER_NAME_KEY] as! String
        userEmail = dict[Constants.EMAIL_KEY] as! String
        if let avatar_link = dict[Constants.PROFILE_PICTURE_KEY] as? String {
            avatar = avatar_link
        }else{
            avatar = ""
        }
        if let bio_link = dict[Constants.PROFILE_BIO_KEY] as? String{
            userBio = bio_link
        }else{
            userBio = ""
        }
        if let phone_link = dict[Constants.PHONE_KEY] as? String{
            userPhone = phone_link
        }else{
            userPhone = ""
        }
    }
}
