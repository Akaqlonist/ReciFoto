//
//  SettingsViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 2/13/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "Settings"
//        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func logoutAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.setHasLoginInfo(status: false)
        appDelegate.saveToUserDefaults()
        
        appDelegate.changeRootViewController(with: "loginNavigationVC")
    }
    @IBAction func tipsAndTrickAction(_ sender: Any) {
        if let url = URL(string: "http://www.wikirecipedia.com/tips-and-tricks/") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func inviteFriendAction(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
//            mail.setToRecipients([""])
            mail.setMessageBody("Try Recifoto, a new app I've downloaded. It is a great way to search, save and share recipes. Get it by clicking the link that is right for you : <a href=\"https://itunes.apple.com/us/app/recifoto/id716483769?mt=8\">Recifoto for iOS</a> <a href=\"https://play.google.com/store/apps/details?id=com.recipe.main&hl=en\">Recifoto for Android</a> <a href=\"http://www.recifoto.com\">Recifoto for Web</a>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    @IBAction func iapAction(_ sender: Any) {
    }
    @IBAction func amazonStoreAction(_ sender: Any) {
        if let url = URL(string: "http://astore.amazon.com/recifoto-20/") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func chefCatalogAction(_ sender: Any) {
        if let url = URL(string: "http://www.chefscatalog.com") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func omahaAction(_ sender: Any) {
        if let url = URL(string: "http://www.omahasteaks.com/shop/") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func zapposAction(_ sender: Any) {
        if let url = URL(string: "http://www.zappos.com") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func contactAction(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@recifoto.com"])
            mail.setSubject("I have this problem/suggestion")
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
