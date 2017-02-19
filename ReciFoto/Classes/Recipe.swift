//
//  Recipe.swift
//  ReciFoto
//
//  Created by Colin Taylor on 2/17/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import Foundation
struct Recipe {
    
    var identifier: String
    let title: String
    var user : User = User()
    let time: Int
    let imageURL: String
    let recipe_website : String
    let contact_phone : String
    let have_contact : String
    let comment_count : Int
    var comments : [Comment] = []
    let likes_count : Int
    
    init(){
        identifier = ""
        title = ""
        user = User()
        time = 0
        imageURL = ""
        recipe_website = ""
        contact_phone = ""
        have_contact = ""
        comment_count = 0
        likes_count = 0
    }
    init(dict: NSDictionary) {
        let recipe = dict[Constants.RECIPE_KEY] as! NSDictionary
        print(recipe)
        identifier = recipe[Constants.RECIPE_ID_KEY] as! String
        title = recipe[Constants.RECIPE_TITLE_KEY] as! String
        user.userName = recipe[Constants.USER_NAME_KEY] as! String
        user.id = recipe[Constants.USER_ID_KEY] as! String
        if let picture_link = recipe[Constants.PROFILE_PICTURE_KEY] as? String
        {
            user.avatar = picture_link
        }
        else {
            user.avatar = ""
        }
        if let time_elapsed = recipe[Constants.TIME_ELAPSED_KEY] as? NSString {
            time = time_elapsed.integerValue
        }else{
            time = 0
        }
        
        imageURL = recipe[Constants.RECIPE_IMAGE_KEY] as! String
        
        recipe_website = recipe[Constants.RECIPE_WEBSITE_KEY] as! String
        contact_phone = recipe[Constants.CONTACT_PHONE_KEY] as! String
        have_contact = recipe[Constants.HAVE_CONTACT_KEY] as! String
        comment_count = (dict[Constants.COMMENT_COUNT_KEY] as! NSString).integerValue
        likes_count = (dict[Constants.LIKES_COUNT_KEY] as! NSString).integerValue
        if let comments_array = dict[Constants.COMMENTS_KEY] as? [AnyObject]
        {
            if comments_array.count > 0 {
                for comment in comments_array {
                    self.comments.append(Comment(dict: comment as! NSDictionary))
                }
            }else{
                //                        self.lblNoRecipePost.isHidden = false
                comments = []
            }
        }
        else{
            comments = []
        }
    }
}
