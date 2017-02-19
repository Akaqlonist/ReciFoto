//
//  RecipeViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 2/14/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class RecipeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    var recipe : Recipe = Recipe()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var imgScrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "Recipe Detail"
        tableView.register(MinimumCommentTableViewCell.self, forCellReuseIdentifier: String(describing: MinimumCommentTableViewCell.self))
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(RecipeViewController.shareAction))
        self.navigationItem.rightBarButtonItem = shareButton
        
        loadRecipe()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadRecipe(){
        self.titleLabel.text = recipe.title
        if (recipe.imageURL.characters.count) > 0 {
            let size = contentImageView.frame.size
            
            contentImageView.af_setImage(
                withURL: URL(string: (recipe.imageURL))!,
                placeholderImage: UIImage.init(named: "PlaceholderImage"),
                filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: 0.0),
                imageTransition: .crossDissolve(0.2)
            )
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
        self.tableView.reloadData()
    }
    func shareAction(){
        let actionSheetController = UIAlertController(title: "ReciFoto", message: "Choose your action", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let facebookActionButton = UIAlertAction(title: "Share to Facebook", style: .default) { action -> Void in
            print("FB Share")
            
        }
        actionSheetController.addAction(facebookActionButton)
        
        let twitterActionButton = UIAlertAction(title: "Share to Twitter", style: .default) { action -> Void in
            print("TW Share")
        }
        actionSheetController.addAction(twitterActionButton)
        
        self.present(actionSheetController, animated: true, completion: nil)
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
    @IBAction func moreAction(_ sender: Any) {
        let actionSheetController = UIAlertController(title: "ReciFoto", message: "Choose your action", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Save to Collection", style: .default) { action -> Void in
            print("Save")
            let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.saveCollection),
                                     method: .post, parameters: [Constants.USER_ID_KEY : Me.user.id,
                                                                 Constants.USER_SESSION_KEY : Me.session_id,
                                                                 Constants.RECIPE_ID_KEY : self.recipe.identifier])
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
                }catch{
                    print("Error Parsing JSON from recipe_like")
                }
                
            })
        }
        actionSheetController.addAction(saveActionButton)
        
        let reportActionButton = UIAlertAction(title: "Report Inappropriate", style: .default) { action -> Void in
            print("Report Inappropriate")
            let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.reportInappropriate),
                                     method: .post, parameters: [Constants.USER_ID_KEY : Me.user.id,
                                                                 Constants.USER_SESSION_KEY : Me.session_id,
                                                                 Constants.RECIPE_ID_KEY : self.recipe.identifier])
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
                }catch{
                    print("Error Parsing JSON from recipe_like")
                }
                
            })
        }
        actionSheetController.addAction(reportActionButton)
        
        self.present(actionSheetController, animated: true, completion: nil)
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
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.recipeLikeV2),
                                 method: .post, parameters: [Constants.USER_ID_KEY : Me.user.id,
                                                             Constants.USER_SESSION_KEY : Me.session_id,
                                                             Constants.RECIPE_ID_KEY : recipe.identifier])
        
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
            }catch{
                print("Error Parsing JSON from recipe_like")
            }
            
        })
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentImageView
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MinimumCommentTableViewCell.self), for: indexPath) as! MinimumCommentTableViewCell
        let comment = recipe.comments[indexPath.row]
        cell.configure(with: comment)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}