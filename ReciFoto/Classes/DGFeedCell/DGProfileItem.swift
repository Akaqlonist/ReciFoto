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
        if let time_elapsed = dict[Constants.TIME_ELAPSED_KEY] as? NSString {
            time = time_elapsed.integerValue
        }else{
            time = 0
        }
        imageURL = dict[Constants.RECIPE_IMAGE_KEY] as! String
        user_id = dict[Constants.USER_ID_KEY] as! String
        if let website_link = dict[Constants.RECIPE_WEBSITE_KEY] as? String {
            recipe_website = website_link
        }else{
            recipe_website = ""
        }
//        recipe_website = dict[Constants.RECIPE_WEBSITE_KEY] as! String
        if let contact_link = dict[Constants.CONTACT_PHONE_KEY] as? String{
            contact_phone = contact_link
        }else{
            contact_phone = ""
        }
//        contact_phone = dict[Constants.CONTACT_PHONE_KEY] as! String
        if let have_contact_link = dict[Constants.HAVE_CONTACT_KEY] as? String{
            have_contact = have_contact_link
        }else{
            have_contact = ""
        }
//        have_contact = dict[Constants.HAVE_CONTACT_KEY] as! String
        
        if let picture_link = dict[Constants.PROFILE_PICTURE_KEY] as? String
        {
            profile_picture = picture_link
        }
        else {
            profile_picture = ""
        }
    }
}
