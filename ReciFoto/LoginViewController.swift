//
//  LoginViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/20/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(_ sender: Any) {
        validation()
    }
    func validation(){
        
        let alertController = UIAlertController(title: "ReciFoto", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if (txtUsername.text?.isEmpty)! || !isValidEmailString(){
            alertController.message = "Please input valid Username or Email"
            self.present(alertController, animated: true, completion: {
                self.txtUsername.becomeFirstResponder()
            })
        }
        else if (txtPassword.text?.isEmpty)!{
            alertController.message = "Password is empty"
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            let apiCode = loginAPI()
            if apiCode == 1{
                
            }else{
                
            }
        }
    }
    func isValidEmailString() -> Bool {
        //        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        //        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        //        return emailPredicate.evaluate(with: txtEmail.text)
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789@.")
        if txtUsername.text?.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        }else{
            let emailCharset = CharacterSet(charactersIn: "@.")
            if txtUsername.text?.rangeOfCharacter(from: emailCharset) != nil{
                return true
            }else{
                return false
            }
        }
    }
    func isValidUsernameString() -> Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
        if txtUsername.text?.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        }else{
            return true
        }
    }
    func loginAPI()->Int{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.loginURLV2),
                                 method: .post, parameters: ["username" : txtUsername.text!,
                                                             "password" : txtPassword.text!,
                                                             "platform" : "ios",
                                                             "deviceToken" : ""])
        
        apiRequest.responseString(completionHandler: { response in
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                print(jsonResponse)
                Profile.user_id = jsonResponse["user_id"] as! Int
                Profile.session_id = jsonResponse["session_id"] as! String
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.changeRootViewController(with: "mainNavigationVC")
            }catch{
                print("Error Parsing JSON from register_user_v2")
            }
            
        })
        
        return 1;
    }
    //Mark: - Animation
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
