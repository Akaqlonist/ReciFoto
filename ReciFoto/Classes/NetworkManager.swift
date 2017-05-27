//
//  NetworkManager.swift
//  ReciFoto
//
//  Created by Colin Taylor on 2/26/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import Foundation
import UIKit

open class NetworkManger : NSObject  {
    static let sharedInstance : NetworkManger = {
        let instance = NetworkManger()
        return instance
    }()
    
    public override init() {
        super.init()
    }
    
}

// MARK: - API

extension NetworkManger {
    func registerAPI(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void){
        print(parameters)
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.registerURLV2), method: .post, parameters: parameters)
        
        apiRequest.responseString(completionHandler: { response in
            do{
                
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                print(jsonResponse)
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                
                if status == "1"{
                    let result = jsonResponse[Constants.RESULT_KEY] as! [String : AnyObject]
                    print(result)
                    let user = result[Constants.USER_KEY] as! NSDictionary
                    Me.session_id = user[Constants.USER_SESSION_KEY] as! String
                    Me.user = User(dict: user)
                    
                }else{
                }
                completionHandler(jsonResponse as NSDictionary, status)
            }catch{
                print("Error Parsing JSON from register_user_v2")
            }
            
        })
    }
    func registerAPISocial(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void){
        print(parameters)
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.loginSocial), method: .post, parameters: parameters)
        
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                print(jsonResponse)
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                
                if status == "1"{
                    let result = jsonResponse[Constants.RESULT_KEY] as! [String : AnyObject]
                    print(result)
                    let user = result[Constants.USER_KEY] as! NSDictionary
                    Me.session_id = user[Constants.USER_SESSION_KEY] as! String
                    Me.user = User(dict: user)
                    
                }else{
                }
                completionHandler(jsonResponse as NSDictionary, status)
            }catch{
                print("Error Parsing JSON from register_user_v2")
            }
            
        })
    }
    func loginAPI(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void){
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.loginURLV2),
                                 method: .post, parameters: parameters)
        
        apiRequest.responseString(completionHandler: { response in
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                print(jsonResponse)
                if status == "1"{
                    let result = jsonResponse[Constants.RESULT_KEY] as! [String : AnyObject]
                    print(result)
                    let user = result[Constants.USER_KEY] as! NSDictionary
                    Me.session_id = user[Constants.USER_SESSION_KEY] as! String
                    Me.user = User(dict: user)
                    
                }else {
                    
                }
                completionHandler(jsonResponse as NSDictionary, status)
            }catch{
                print("Error Parsing JSON from login_user_v2")
            }
        })
    }
    func trendsAPI(parameters: [String : String],didFinishedWithResult: @escaping(Int) -> Void){
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getTrendsV2),
                                 method: .post, parameters: parameters)
        
        apiRequest.responseString(completionHandler: { response in
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                
            }catch{
                
                print("Error Parsing JSON from get_trends")
            }
            
        })
        didFinishedWithResult(0)
    }
    func searchAPI(parameters: [String : String],  didFinishedWithResult: @escaping(Int) -> Void){
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.recipeSearchV2),
                                 method: .post, parameters: parameters)
        
        apiRequest.responseString(completionHandler: { response in
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
            }catch{
                print("Error Parsing JSON from get_search")
            }
            didFinishedWithResult(0)
        })
    }
    func feedAPIByIndex(parameters: [String : String],index: Int, didFinishedWithResult: @escaping(Int) -> Void) -> Void{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getUserRecipesV2),
                                 method: .post, parameters: parameters)
        
        apiRequest.responseString(completionHandler: { response in
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
            }catch{
                print("Error Parsing JSON from get_feed_by_index")
            }
            didFinishedWithResult(0)
        })
    }
    func likeAPI(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void){
//        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.recipeLikeV2),
                                 method: .post, parameters: parameters)
        
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                
                if status == "1"{
                    print(jsonResponse)
                }else {
                    
                }
                completionHandler(jsonResponse as NSDictionary, status)
//                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }catch{
//                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                print("Error Parsing JSON from recipe_like")
            }
            
        })
    }
    func saveCollectionAPI(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.saveCollection),
                                 method: .post, parameters: parameters)
        print(Me.user.id)
        print(Me.session_id)
        apiRequest.responseString(completionHandler: { response in
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                print(jsonResponse)
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                
                if status == "1"{
                    
                }else {
                    
                }
                completionHandler(jsonResponse as NSDictionary, status)
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }catch{
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                print("Error Parsing JSON from recipe_like")
            }
            
        })
    }
    func reportRecipeAPI(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.reportInappropriate),
                                 method: .post, parameters: parameters)
        print(Me.user.id)
        print(Me.session_id)
        apiRequest.responseString(completionHandler: { response in
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                print(jsonResponse)
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                
                if status == "1"{
                    
                }else {
                    
                }
                completionHandler(jsonResponse as NSDictionary, status)
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }catch{
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                print("Error Parsing JSON from recipe_like")
            }
            
        })
    }
    func deleteRecipeAPI(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.deleteRecipe),
                                 method: .post, parameters: parameters)
        print(Me.user.id)
        print(Me.session_id)
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                print(jsonResponse)
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                
                if status == "1"{
                    print(jsonResponse)
                }else {
                    
                }
                completionHandler(jsonResponse as NSDictionary, status)
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }catch{
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                print("Error Parsing JSON from recipe_like")
            }
            
        })
    }
    func profileAPIByIndex(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void) -> Void{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getProfileV2),
                                 method: .post, parameters: parameters)
        
        apiRequest.responseString(completionHandler: { response in
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                completionHandler(jsonResponse as NSDictionary, status)
            }catch{
                print("Error Parsing JSON from get_profile")
            }
            
        })
    }
    func commentAPIByIndex(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void) -> Void{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getCommentsByIndexV2),
                                 method: .post, parameters: parameters)
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                completionHandler(jsonResponse as NSDictionary, status)
            }catch{
                print("Error Parsing JSON from get_feed_by_index")
            }
            
        })
    }
    func addCommentAPI(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void) -> Void{
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.addComment),
                                 method: .post, parameters: parameters)
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                
                completionHandler(jsonResponse as NSDictionary, status)
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }catch{
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                print("Error Parsing JSON from addComment")
            }
            
        })
    }
    func updateCommentAPI(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void) -> Void{
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.updateComment),
                                 method: .post, parameters: parameters)
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                completionHandler(jsonResponse as NSDictionary, status)
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }catch{
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                print("Error Parsing JSON from addComment")
            }
            
        })
    }
    func collectionAPIByIndex(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void) -> Void{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getCollectionByIndex),
                                 method: .post, parameters: parameters)
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                completionHandler(jsonResponse as NSDictionary, status)
            }catch{
                print("Error Parsing JSON from get_collection_by_index")
            }
            
        })
    }
    func updateProfileAPI(completionHandler: @escaping (NSDictionary, String) -> Void) -> Void{
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        let parameters = [Constants.USER_ID_KEY : Me.user.id,
                          Constants.USER_SESSION_KEY : Me.session_id,
                          Constants.PHONE_KEY : Me.user.userPhone,
                          Constants.USER_FULL_NAME_KEY : Me.user.userFullName,
                          Constants.USER_BIO_KEY : Me.user.userBio,
                          Constants.USER_BIRTHDAY_KEY : Me.user.userBirthday,
                          Constants.USER_NAME_KEY : Me.user.userName
                          ];
        print(parameters)
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.updateProfileV2),
                                 method: .post, parameters: parameters)
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                completionHandler(jsonResponse as NSDictionary, status)
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }catch{
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                print("Error Parsing JSON from get_collection_by_index")
            }
            
        })
    }
    func updateProfileWithPhotoAPI(image : UIImage,completionHandler: @escaping (NSDictionary, String) -> Void) -> Void{
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        let uploadAPIURLConvertable = String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.updateProfileWithPhotoV2)
        upload(multipartFormData: { multipartFormData in
            multipartFormData.append(UIImagePNGRepresentation(image)!, withName: "file", fileName: "file.png", mimeType: "image/png")
            multipartFormData.append(Me.user.id.data(using: .utf8)!, withName: Constants.USER_ID_KEY)
            multipartFormData.append(Me.session_id.data(using: .utf8)!, withName: Constants.USER_SESSION_KEY)
            multipartFormData.append(Me.user.userPhone.data(using: .utf8)!, withName: Constants.PHONE_KEY)
            multipartFormData.append(Me.user.userFullName.data(using: .utf8)!, withName: Constants.USER_FULL_NAME_KEY)
            multipartFormData.append(Me.user.userBio.data(using: .utf8)!, withName: Constants.USER_BIO_KEY)
            multipartFormData.append(Me.user.userBirthday.data(using: .utf8)!, withName: Constants.USER_BIRTHDAY_KEY)
            multipartFormData.append(Me.user.userName.data(using: .utf8)!, withName: Constants.USER_NAME_KEY)
        }, to: uploadAPIURLConvertable)
        { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    }
                }
                
            case .failure(let encodingError):
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                print("error:\(encodingError)")
            }
            
        }
    }
    func followToAPI(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void) -> Void{
        
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.followTo),
                                 method: .post, parameters: parameters)
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                completionHandler(jsonResponse as NSDictionary, status)
            }catch{
                print("Error Parsing JSON from addComment")
            }
            
        })
    }
    func unfollowToAPI(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void) -> Void{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.unfollowTo),
                                 method: .post, parameters: parameters)
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                completionHandler(jsonResponse as NSDictionary, status)
            }catch{
                
                print("Error Parsing JSON from addComment")
            }
            
        })
    }
    func getFollowersAPI(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void) -> Void{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getFollowers),
                                 method: .post, parameters: parameters)
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                completionHandler(jsonResponse as NSDictionary, status)
            }catch{
                print("Error Parsing JSON from addComment")
            }
            
        })
    }
    func getFollowigsAPI(parameters: [String : String],completionHandler: @escaping (NSDictionary, String) -> Void) -> Void{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getFollowings),
                                 method: .post, parameters: parameters)
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                completionHandler(jsonResponse as NSDictionary, status)
            }catch{
                print("Error Parsing JSON from addComment")
            }
            
        })
    }
}
