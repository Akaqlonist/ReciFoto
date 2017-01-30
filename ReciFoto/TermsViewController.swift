//
//  TermsViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/26/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet weak var termsWebview: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = Bundle.main.url(forResource: "TermsPrivacy", withExtension: "html")
        let request = NSURLRequest(url: url!)
        termsWebview.loadRequest(request as URLRequest)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
