//
//  User.swift
//  NewsFeed
//
//  Created by Alex Manzella on 08/07/16.
//  Copyright © 2016 devlucky. All rights reserved.
//

import Foundation

struct User {
    
    let id: String
    let username: String
    let avatar: String
    
    init(id: String) {
        self.id = id
        username = ""
        avatar = ""
    }
    init (dict: NSDictionary){
        id = dict[Constants.USER_ID_KEY] as! String
        username = dict[Constants.USER_NAME_KEY] as! String
        avatar = dict[Constants.USER_PICTURE_KEY] as! String
    }
}
