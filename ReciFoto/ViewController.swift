//
//  ViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/18/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
import TwitterCore

class ViewController: UIViewController {

    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnTw: UIButton!
    @IBOutlet weak var btnFB: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func registerAction(_ sender: Any) {
    }
    
    @IBAction func loginAction(_ sender: Any) {
    }
    
    @IBAction func twitterAction(_ sender: Any) {
        Twitter.sharedInstance().logIn(withMethods: .webBased) { (session, error) in
            let client = TWTRAPIClient.withCurrentUser()
            let request = client.urlRequest(withMethod: "GET",
                                            url: "https://api.twitter.com/1.1/account/verify_credentials.json",
                                                      parameters: ["include_email": "true", "skip_status": "true"],
                                                      error: nil)
            client.sendTwitterRequest(request, completion: { (response, data, connectionError) in
                
                do{
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
                    print(jsonResponse)
//                    ["username" : txtUsername.text!, "email" : txtEmail.text!, "password" : txtPassword.text!]
                    var parameters : [String : String] = [:]
                    parameters[Constants.USER_NAME_KEY] = jsonResponse[Constants.SCREEN_NAME_KEY] as? String
                    if let email = jsonResponse[Constants.EMAIL_KEY] as? String {
                        parameters[Constants.EMAIL_KEY] = email
                    }else{
//                        parameters[Constants.EMAIL_KEY] = "colintaylor1016@gmail.com"
                        let alertController = UIAlertController(title: "ReciFoto", message: "Unable to get email address", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    parameters[Constants.PLATFORM_KEY] = "ios"
                    parameters[Constants.USER_FULL_NAME_KEY] = jsonResponse["name"] as! String?
                    parameters[Constants.PROFILE_PIC_KEY] = jsonResponse["profile_image_url"] as! String?
                    parameters[Constants.BIO_KEY] = jsonResponse["description"] as! String?
                    NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
                    NetworkManger.sharedInstance.registerAPISocial(parameters: parameters, completionHandler: { (jsonResponse, status) in
                        print(jsonResponse)
                        if status == "1"{
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            
                            appDelegate.setHasLoginInfo(status: true)
                            appDelegate.saveToUserDefaults()
                            
                            appDelegate.changeRootViewController(with: "mainTabVC")
                        }else{
                            let alertController = UIAlertController(title: "ReciFoto", message: jsonResponse[Constants.MESSAGE_KEY] as! String?, preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    })
                }catch{
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    print("error")
                }
                
            })
            
        }
        
    }

    @IBAction func fbLoginAction(_ sender: Any) {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()

        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        fbLoginManager.logOut()
                    }
                }
            }
        }
    }
    
    func getFBUserData(){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    var parameters : [String : String] = [:]
                    let email = data[Constants.EMAIL_KEY] as! String
                    parameters[Constants.EMAIL_KEY] = email
                    parameters[Constants.USER_NAME_KEY] = email.components(separatedBy: "@")[0]
                    parameters[Constants.PLATFORM_KEY] = "ios"
                    parameters[Constants.USER_FULL_NAME_KEY] = data["name"] as! String?
                    let picture = ((data["picture"] as! NSDictionary)["data"] as! NSDictionary)["url"] as! String
                    parameters[Constants.PROFILE_PIC_KEY] = picture
                    
                    NetworkManger.sharedInstance.registerAPISocial(parameters: parameters, completionHandler: { (jsonResponse, status) in
                        if status == "1"{
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            
                            appDelegate.setHasLoginInfo(status: true)
                            appDelegate.saveToUserDefaults()
                            
                            appDelegate.changeRootViewController(with: "mainTabVC")
                        }else{
                            let alertController = UIAlertController(title: "ReciFoto", message: jsonResponse[Constants.MESSAGE_KEY] as! String?, preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    })
                    
                }
            })
        }
    }
    
}

