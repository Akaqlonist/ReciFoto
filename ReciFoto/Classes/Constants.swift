//
//  Constants.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/26/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

struct Constants{
    
    //API Level
    static let API_URL_DEVELOPMENT = "http://192.168.1.136/recifoto/index.php/api/"
    static let API_URL_PRODUCTION = "http://www.recifoto.com/api/"
    static let registerURL = "register_user"
    static let registerURLV2 = "register_user_v2"
    static let loginURL = "login_user"
    static let loginURLV2 = "login_user_v2"
    static let getFeedByIndex = "get_feed_by_index"
    static let getUserRecipesV2 = "get_user_recipesV2"
    static let getProfileV2 = "get_profileV2"
    static let getTrendsV2 = "get_trendsV2"
    
    //Static Keys
    static let USER_EMAIL_KEY = "user_email"
    static let USER_ID_KEY = "user_id"
    static let USER_PASSWORD_KEY = "user_password"
    static let USER_SESSION_KEY = "session_id"
    static let USER_NAME_KEY = "user_name"
    static let USER_BIO_KEY = "user_bio"
    static let BIO_KEY = "bio"
    static let USER_PICTURE_KEY = "user_picture"
    static let HAS_LOGIN_KEY = "has_login"
    static let LAUNCHED_BEFORE_KEY = "launched_before"
    static let RECIPE_ID_KEY = "recipe_id"
    static let CONTACT_PHONE_KEY = "contact_phone"
    static let HAVE_CONTACT_KEY = "have_contact"
    static let PROFILE_PICTURE_KEY = "profile_picture"
    static let PICTURE_KEY = "picture"
    static let RECIPE_IMAGE_KEY = "recipe_image"
    static let RECIPE_TITLE_KEY = "recipe_title"
    static let RECIPE_WEBSITE_KEY = "recipe_website"
    static let TIME_ELAPSED_KEY = "time_elapsed"
    static let COMMENT_COUNT_KEY = "comment_count"
    static let COMMENTS_KEY = "comments"
    static let LIKES_COUNT_KEY = "likes_count"
    static let RECIPE_KEY = "recipe"
    static let STATUS_KEY = "status"
    static let MESSAGE_KEY = "message"
    static let RESULT_KEY = "result"
    static let PROFILE_KEY = "profile"
    static let FOLLOWER_KEY = "follower"
    static let RECIPE_COUNT_KEY = "recipe_count"
    static let FOLLOWING_KEY = "following"
    static let IS_FOLLOW_KEY = "is_follow"
}
