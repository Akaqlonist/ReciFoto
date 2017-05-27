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
    let max_length = 180
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        return textView
    }()
    private let titleLabel : UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = .center
        titleLabel.text = "180 left"
        return titleLabel
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
        self.navigationItem.titleView = titleLabel
        
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
        NetworkManger.sharedInstance.addCommentAPI(parameters: [Constants.USER_ID_KEY : Me.user.id,
                                                                Constants.USER_SESSION_KEY : Me.session_id,
                                                                Constants.RECIPE_ID_KEY : recipe_id,
                                                                Constants.COMMENTS_KEY : textView.text,
                                                                Constants.IS_COMMENT_PRIVATE : "0"]) { (jsonResponse, status) in
            if status == "1"{
                
            }else {
                
                let alertController = UIAlertController(title: "ReciFoto", message: jsonResponse["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        titleLabel.text = String(format: "%d left", max_length - textView.text.characters.count)
        navigationItem.rightBarButtonItem?.isEnabled = textView.text.characters.count > 0
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.characters.count < 180 {
            return true
        }else{
            return false
        }
    }
}
