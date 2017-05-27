//
//  LoginViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/20/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var submitView: UIView!
    var offsetKeyboard : CGFloat = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        if UIDevice.current.userInterfaceIdiom == .phone {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIDevice.current.userInterfaceIdiom == .phone{
            
        }else{
            self.submitView.frame.origin.y = UIScreen.main.bounds.size.height - offsetKeyboard
        }
    }
    @IBAction func loginAction(_ sender: Any) {
        validation()
    }
    func validation(){
        
        let alertController = UIAlertController(title: "ReciFoto", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if (txtUsername.text?.isEmpty)! || !isValidUsernameString(){
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
            let parameters : [String : String] = ["username" : txtUsername.text!,
                                                  "password" : txtPassword.text!,
                                                  "platform" : "ios",
                                                  "deviceToken" : ""]
            
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
            NetworkManger.sharedInstance.loginAPI(parameters: parameters, completionHandler: { (jsonResponse, status) in
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
    }
    func isValidEmailString() -> Bool {
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
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789@.")
        if txtUsername.text?.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        }else{
            return true
        }
    }
    //Mark: - Animation
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if UIDevice.current.userInterfaceIdiom == .phone {
                if self.view.frame.origin.y == 0{
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }else{
                let submitTopY = UIScreen.main.bounds.size.height - self.submitView.frame.size.height - keyboardSize.height
                self.submitView.frame.origin.y = submitTopY
                self.offsetKeyboard = self.submitView.frame.size.height + keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if UIDevice.current.userInterfaceIdiom == .phone {
                if self.view.frame.origin.y != 0{
                    self.view.frame.origin.y += keyboardSize.height
                }
            }else{
                self.offsetKeyboard = self.submitView.frame.size.height
                let submitTopY = UIScreen.main.bounds.size.height - self.submitView.frame.size.height
                if self.submitView.frame.origin.y != submitTopY{
                    self.submitView.frame.origin.y += keyboardSize.height
                }
            }
        }
    }
    ///////////////////////////////////////////////////////////////
    //UITextFieldDelegate Method
    ///////////////////////////////////////////////////////////////
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
