//
//  Comment.swift
//  NewsFeed
//
//  Created by Alex Manzella on 08/07/16.
//  Copyright © 2016 devlucky. All rights reserved.
//

import Foundation

struct Comment {
    
    let id: String
    let author: User
    let text: String
    let time : Int
    
    init(id: String) {
        self.id = id
        author = User(id: "")
        text = ""
        time = 0
    }
    init(dict : NSDictionary){
        text = dict["comment"] as! String
        time = (dict["time_elapsed"] as! NSString).integerValue
        author = User(dict : dict)
        id = dict["comment_id"] as! String
    }
}
