//
//  DGProfileItem.swift
//  ReciFoto
//
//  Created by Colin Taylor on 2/7/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import Foundation
struct DGProfileItem {
    
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
    
    init(dict: NSDictionary) {
        identifier = dict[Constants.RECIPE_ID_KEY] as! String
        title = dict[Constants.RECIPE_TITLE_KEY] as! String
        userName = dict[Constants.USER_NAME_KEY] as! String
        time = (dict[Constants.TIME_ELAPSED_KEY] as! NSString).integerValue
        imageURL = dict[Constants.RECIPE_IMAGE_KEY] as! String
        user_id = dict[Constants.USER_ID_KEY] as! String
        recipe_website = dict[Constants.RECIPE_WEBSITE_KEY] as! String
        contact_phone = dict[Constants.CONTACT_PHONE_KEY] as! String
        have_contact = dict[Constants.HAVE_CONTACT_KEY] as! String
        
        if let picture_link = dict[Constants.PROFILE_PICTURE_KEY] as? String
        {
            profile_picture = picture_link
        }
        else {
            profile_picture = ""
        }
    }
}
