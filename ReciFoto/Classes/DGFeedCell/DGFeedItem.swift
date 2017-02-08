//
//  DGFeedItem.swift
//  TemplateLayoutDemo
//
//  Created by zhaodg on 11/26/15.
//  Copyright © 2015 zhaodg. All rights reserved.
//

import Foundation

struct DGFeedItem {

    var identifier: String
    let title: String
    let userName: String
    let time: Int
    let imageURL: String
    let user_id : String
    let recipe_website : String
    let contact_phone : String
    let have_contact : String
    let profile_picture : String
    let comment_count : Int
    let comments : [AnyObject]
    let likes_count : Int
    
    init(dict: NSDictionary) {
        let recipe = dict[Constants.RECIPE_KEY] as! NSDictionary
        print(recipe)
        identifier = recipe[Constants.RECIPE_ID_KEY] as! String
        title = recipe[Constants.RECIPE_TITLE_KEY] as! String
        userName = recipe[Constants.USER_NAME_KEY] as! String
        time = (recipe[Constants.TIME_ELAPSED_KEY] as! NSString).integerValue
        imageURL = recipe[Constants.RECIPE_IMAGE_KEY] as! String
        user_id = recipe[Constants.USER_ID_KEY] as! String
        recipe_website = recipe[Constants.RECIPE_WEBSITE_KEY] as! String
        contact_phone = recipe[Constants.CONTACT_PHONE_KEY] as! String
        have_contact = recipe[Constants.HAVE_CONTACT_KEY] as! String
        
        if let picture_link = recipe[Constants.PROFILE_PICTURE_KEY] as? String
        {
            profile_picture = picture_link
        }
        else {
            profile_picture = ""
        }
        
        comment_count = (dict[Constants.COMMENT_COUNT_KEY] as! NSString).integerValue
        likes_count = (dict[Constants.LIKES_COUNT_KEY] as! NSString).integerValue
        if let comments_array = dict[Constants.COMMENTS_KEY] as? [AnyObject]
        {
            comments = comments_array
        }
        else{
            comments = [AnyObject]()
        }
    }
}
