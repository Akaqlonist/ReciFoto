//
//  SettingsViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 2/13/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "Settings"
        self.navigationItem.setHidesBackButton(true, animated: false)
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
}
