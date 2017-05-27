//
//  RecipeViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 2/14/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit
import FBSDKShareKit
import TwitterKit
import TwitterCore

class RecipeViewController: UIViewController, UIScrollViewDelegate, FBSDKSharingDelegate, UITextViewDelegate {
    var recipe : Recipe = Recipe()
    var is_changed : Bool = false
    var private_comment_id : String = "0"
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var titleLabel: LinkLabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var imgScrollView: UIScrollView!
    @IBOutlet weak var privateCommentTextView: UITextView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var remainLabel: UILabel!
    
    @IBOutlet weak var imgScrollConstraintEqualWidth: NSLayoutConstraint!
    var shareButton = UIBarButtonItem()
    let textLimit = 180
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "Recipe Detail"
        
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(RecipeViewController.shareAction))
        self.navigationItem.rightBarButtonItem = shareButton
        NotificationCenter.default.addObserver(self, selector: #selector(RecipeViewController.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
        [NSNotification.Name.UIKeyboardWillShow, NSNotification.Name.UIKeyboardWillChangeFrame, NSNotification.Name.UIKeyboardWillHide].forEach { (name) in
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameDidChange(_:)), name: name, object: nil)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapForComment))
        self.imgScrollView.addGestureRecognizer(tapGesture)
        
        loadRecipe()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func didTapForComment(){
        self.commentView.isHidden = !self.commentView.isHidden
    }
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        coordinator.animateAlongsideTransition(in: self.view, animation: { coordinatorContext in
//            let orient = UIApplication.shared.statusBarOrientation
//            
//            switch orient {
//            case .portrait, .portraitUpsideDown:
//                print("Portrait")
//                self.applyPortraitConstraint()
//                break
//            // Do something
//            default:
//                print("LandScape")
//                // Do something else
//                self.applyLandscapeConstraint()
//                break
//            }
//        }) { coordinatorContext in
//            print("rotation completed")
//        }
//
//        super.viewWillTransition(to: size, with: coordinator)
//    }
    
    //Mark: - Animation
    @objc private func keyboardFrameDidChange(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
    }
    func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else { return }
        
        for (_, product) in RecifotoProducts.products.enumerated() {
            guard product.productIdentifier == productID else { continue }
            self.saveCollection()
        }
    }
    func loadRecipe(){
//        self.titleLabel.text = recipe.title
        
        let text = recipe.title
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = self.titleLabel.font.pointSize * 1.5
        paragraphStyle.maximumLineHeight = self.titleLabel.font.pointSize * 1.5
        
        self.titleLabel.attributedText = NSAttributedString(string: text, attributes: [
            NSParagraphStyleAttributeName: paragraphStyle
            ])
        
        if recipe.recipe_website.characters.count > 0{
            print(recipe.recipe_website)
            print(URL(string: recipe.recipe_website) ?? "default url")
            _ = self.titleLabel.addLink(url: URL(string: recipe.recipe_website)!, range: NSMakeRange(0, text.characters.count), linkAttribute: [
                NSFontAttributeName : UIFont.italicSystemFont(ofSize: self.titleLabel.font.pointSize),
                NSForegroundColorAttributeName: UIColor.white,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject
                ], selection: { (url) in
//                    self.delegate?.didLinkClickedWithItem(item: recipe, url: url)
                    let actionSheetController = UIAlertController(title: "ReciFoto", message: "Choose your action", preferredStyle: .actionSheet)
                    
                    let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                        print("Cancel")
                    }
                    actionSheetController.addAction(cancelActionButton)
                    
                    let openActionButton = UIAlertAction(title: "Open Website", style: .default) { action -> Void in
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                            
                        })
                    }
                    actionSheetController.addAction(openActionButton)
                    
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        self.present(actionSheetController, animated: true, completion: nil)
                    }else{
                        actionSheetController.modalPresentationStyle = .popover
                        let popOver: UIPopoverPresentationController = actionSheetController.popoverPresentationController!
                        popOver.sourceView = self.titleLabel
                        popOver.sourceRect = self.titleLabel.bounds
                        popOver.permittedArrowDirections = .up
                        self.present(actionSheetController, animated: true, completion: {
                            
                        })
                    }
            })
        }
        
        if (recipe.imageURL.characters.count) > 0 {
//            let size = contentImageView.frame.size
            contentImageView.af_setImage(withURL: URL(string: (recipe.imageURL))!)
//            contentImageView.af_setImage(
//                withURL: URL(string: (recipe.imageURL))!,
//                placeholderImage: UIImage.init(named: "PlaceholderImage"),
//                filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: 0.0),
//                imageTransition: .crossDissolve(0.2)
//            )
        }
        if (recipe.user.avatar.characters.count) > 0 {
            let size = avatarImageView.frame.size
            
            avatarImageView.af_setImage(
                withURL: URL(string: (recipe.user.avatar))!,
                placeholderImage: UIImage.init(named: "avatar"),
                filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: 30.0),
                imageTransition: .crossDissolve(0.2)
            )
        }
        
        self.userNameLabel.text = recipe.user.userName
        
        if recipe.time < 60 {
            self.timeLabel.text = String(format: "%ds ago", recipe.time)
        }else if recipe.time < 3600 {
            self.timeLabel.text = String(format: "%dm ago", recipe.time / 60)
        }else if recipe.time < 86400 {
            self.timeLabel.text = String(format: "%dh ago", recipe.time / 3600)
        }else{
            self.timeLabel.text = String(format: "%dd ago", recipe.time / 86400)
        }
        self.lblLikes.text = String(format: "%d", recipe.likes_count)
        self.lblComments.text = String(format: "%d",recipe.comment_count)
        
        self.privateCommentTextView.text = getPrivateComment(comments: recipe.comments)
    }
    func getPrivateComment(comments: [Comment]) -> String{
        for comment in comments{
            print(comment)
            if comment.is_private == 1 && comment.author.id == Me.user.id{
                private_comment_id = comment.id
                return comment.text
            }
        }
        return ""
    }
    func shareAction(){
        let actionSheetController = UIAlertController(title: "ReciFoto", message: "Choose your action", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let facebookActionButton = UIAlertAction(title: "Share to Facebook", style: .default) { action -> Void in
            let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
            content.contentTitle = "Recifoto"
            content.contentDescription = self.recipe.title
            content.contentURL = URL(string: self.recipe.imageURL)
            FBSDKShareDialog.show(from: self, with: content, delegate: self)
        }
        actionSheetController.addAction(facebookActionButton)

        let twitterActionButton = UIAlertAction(title: "Share to Twitter", style: .default) { action -> Void in
//            if let twSession = Twitter.sharedInstance().sessionStore.session(){
            let account = ACAccountStore()
            let accountType = account.accountType(
                withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
            
            account.requestAccessToAccounts(with: accountType, options: nil,
                                            completion: {(success, error) in
                                                
                if success {
                    // Get account and communicate with Twitter API
                    let arrayOfAccounts =
                        account.accounts(with: accountType)
                    
                    if (arrayOfAccounts?.count)! > 0 {
                        let composer = TWTRComposer()
                        
                        composer.setText(self.recipe.title)
                        composer.setImage(self.contentImageView.image)
                        
                        // Called from a UIViewController
                        composer.show(from: self, completion: { result in
                            print(result)
                            for subview in self.view.subviews{
                                print(subview)
                            }
                            
                            if (result == TWTRComposerResult.cancelled) {
                                print("Tweet composition cancelled")
                            }
                            else {
                                print("Sending tweet!")
                            }
                            
                        })
                    }else{
                        let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString) as! URL
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                    
                }else{
                    print(error ?? "error on account twitter")
                }
            })
            
//            }
        }
        actionSheetController.addAction(twitterActionButton)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(actionSheetController, animated: true, completion: nil)
        }else{
            actionSheetController.modalPresentationStyle = .popover
            let popOver: UIPopoverPresentationController = actionSheetController.popoverPresentationController!
            popOver.barButtonItem = self.navigationItem.rightBarButtonItem
            popOver.permittedArrowDirections = .up
            self.present(actionSheetController, animated: true, completion: {
                
            })
        }
    }
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print("fb share success")
    }
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print(error)
        print("fb share failed")
    }
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("fb share canceled")
    }
    @IBAction func profileAction(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController {
            if let navigator = navigationController {
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                viewController.user = recipe.user
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    @IBAction func doneAction(_ sender: Any) {
        if is_changed {
            if private_comment_id == "0" {
                NetworkManger.sharedInstance.addCommentAPI(parameters: [Constants.USER_ID_KEY : Me.user.id,
                                                                        Constants.USER_SESSION_KEY : Me.session_id,
                                                                        Constants.RECIPE_ID_KEY : recipe.identifier,
                                                                        Constants.COMMENTS_KEY : privateCommentTextView.text,
                                                                        Constants.IS_COMMENT_PRIVATE : "1"]) { (jsonResponse, status) in
                    if status == "1"{
                        
                    }else {
                        
                        let alertController = UIAlertController(title: "ReciFoto", message: jsonResponse["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    self.commentView.isHidden = true
                }
            }else{
                NetworkManger.sharedInstance.updateCommentAPI(parameters: [Constants.USER_ID_KEY : Me.user.id,
                                                                           Constants.USER_SESSION_KEY : Me.session_id,
                                                                           Constants.COMMENT_ID_KEY : private_comment_id,
                                                                           Constants.COMMENTS_KEY : privateCommentTextView.text], completionHandler: { (jsonResponse, status) in
                    if status == "1"{
                        
                    }else {
                        
                        let alertController = UIAlertController(title: "ReciFoto", message: jsonResponse["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    self.commentView.isHidden = true
                })
            }
        }
    }
    @IBAction func saveAction(_ sender: Any) {
//        let product = RecifotoProducts.products[0]
//        
//        if RecifotoProducts.store.isProductPurchased(product.productIdentifier){
//            self.saveCollection()
//        }else{
//            RecifotoProducts.store.buyProduct(product)
//        }
        saveCollection()
    }
    @IBAction func moreAction(_ sender: UIButton) {
        let actionSheetController = UIAlertController(title: "ReciFoto", message: "Choose your action", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Save to Collection", style: .default) { action -> Void in
            print("Save")
//            let product = RecifotoProducts.products[0]
//            
//            if RecifotoProducts.store.isProductPurchased(product.productIdentifier){
//                self.saveCollection()
//            }else{
//                RecifotoProducts.store.buyProduct(product)
//            }
            self.saveCollection()
        }
        actionSheetController.addAction(saveActionButton)
        
        let reportActionButton = UIAlertAction(title: "Flag as Inappropriate", style: .default) { action -> Void in
            print("Flag as Inappropriate")
            NetworkManger.sharedInstance.reportRecipeAPI(parameters: [Constants.USER_ID_KEY : Me.user.id,
                                                                      Constants.USER_SESSION_KEY : Me.session_id,
                                                                      Constants.RECIPE_ID_KEY : self.recipe.identifier], completionHandler: { (jsonResponse, status) in
                if status == "1"{
                    print(jsonResponse)
                }else {
                    
                }
            })
        }
        actionSheetController.addAction(reportActionButton)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(actionSheetController, animated: true, completion: nil)
        }else{
            actionSheetController.modalPresentationStyle = .popover
            let popOver: UIPopoverPresentationController = actionSheetController.popoverPresentationController!
            popOver.sourceView = sender
            popOver.sourceRect = sender.frame
            popOver.permittedArrowDirections = .down
            self.present(actionSheetController, animated: true, completion: {
                
            })
        }
    }
    @IBAction func commentAction(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "commentsVC") as? CommentsViewController {
            if let navigator = navigationController {
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                viewController.recipe_id = recipe.identifier
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    @IBAction func likeAction(_ sender: Any) {
        self.lblLikes.text = String(format: "%d", recipe.likes_count+1)
        NetworkManger.sharedInstance.likeAPI(parameters: [Constants.USER_ID_KEY : Me.user.id,
                                                          Constants.USER_SESSION_KEY : Me.session_id,
                                                          Constants.RECIPE_ID_KEY : recipe.identifier]) { (jsonResponse, status) in
                                                            
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentImageView
    }
    func saveCollection(){
        NetworkManger.sharedInstance.saveCollectionAPI(parameters: [Constants.USER_ID_KEY : Me.user.id,
                                                                    Constants.USER_SESSION_KEY : Me.session_id,
                                                                    Constants.RECIPE_ID_KEY : recipe.identifier]) { (jsonResponse, status) in
                                                                        
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        is_changed = true
        let len = privateCommentTextView.text.characters.count
        self.remainLabel.text = String(format: "%li", self.textLimit - len)
    }

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return recipe.comments.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MinimumCommentTableViewCell.self), for: indexPath) as! MinimumCommentTableViewCell
//        let comment = recipe.comments[indexPath.row]
//        cell.configure(with: comment)
//        return cell
//    }
//    
//    // MARK: UITableViewDelegate
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
}
