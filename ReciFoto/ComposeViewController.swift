//
//  ComposeViewController.swift
//  NewsFeed
//
//  Created by Alex Manzella on 28/07/16.
//  Copyright © 2016 devlucky. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate {
    
    var recipe_id = ""
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        return textView
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        view.addSubview(textView)
        textView.delegate = self
        textView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        [NSNotification.Name.UIKeyboardWillShow, NSNotification.Name.UIKeyboardWillChangeFrame, NSNotification.Name.UIKeyboardWillHide].forEach { (name) in
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameDidChange(_:)), name: name, object: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    
    // MARK: Actions

    @objc private func keyboardFrameDidChange(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        textView.snp.updateConstraints { (make) in
            make.bottom.equalTo(view).inset(frame.cgRectValue.height)
        }
    }

    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func done() {
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.addComment),
                                 method: .post, parameters: [Constants.USER_ID_KEY : Me.user.id,
                                                             Constants.USER_SESSION_KEY : Me.session_id,
                                                             Constants.RECIPE_ID_KEY : recipe_id,
                                                             Constants.COMMENTS_KEY : textView.text])
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                print(jsonResponse)
                if status == "1"{
                    
                }else {
                    
                    let alertController = UIAlertController(title: "ReciFoto", message: jsonResponse["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }catch{
                
                print("Error Parsing JSON from addComment")
            }
            
        })
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = textView.text.characters.count > 0
    }
}
