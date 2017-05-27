//
//  ProfileViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/20/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    var feedList: [Recipe] = []
    var currentIndex = 0
    var settingButton : UIBarButtonItem?//()
    var followButton : UIBarButtonItem?
    var user = Me.user
    var is_following = false
    
    fileprivate let kCellIdentifier = "pCollectionCell"
    fileprivate var scrolling = false
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblRecipes: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var lblUsername: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let titleButton =  UIButton(type: .custom)
        titleButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleButton.backgroundColor = UIColor.clear
        titleButton.setTitle("Profile", for: .normal)
        titleButton.addTarget(self, action: #selector(self.clickOnTitleButton), for: .touchUpInside)
        self.navigationItem.titleView = titleButton
        
        if user.id == Me.user.id {
            var settingImage = UIImage(named: "gear")
            settingImage = settingImage?.withRenderingMode(.alwaysOriginal)
            settingButton = UIBarButtonItem(image: settingImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProfileViewController.settingAction))
            self.navigationItem.rightBarButtonItem = settingButton
        }else{
            followButton = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(ProfileViewController.followAction))
            
            self.navigationItem.rightBarButtonItem = followButton
        }
        loadFromServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionView.reloadData()
    }
    func clickOnTitleButton(titleButton: UIButton) {
        self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                          at: .top,
                                          animated: true)
    }
    func settingAction(){
        self.performSegue(withIdentifier: "showSettings", sender: self)
    }
    func followAction(){
        let parameters = [Constants.USER_ID_KEY : Me.user.id,
                          Constants.USER_SESSION_KEY : Me.session_id,
                          Constants.TOUSERID_KEY : user.id,
                         ]
        if is_following{
            NetworkManger.sharedInstance.unfollowToAPI(parameters: parameters, completionHandler: { (jsonResponse, status) in
                self.is_following = false
                self.followButton?.title = "Follow"
            })
        }else{
            NetworkManger.sharedInstance.followToAPI(parameters: parameters, completionHandler: { (jsonResponse, status) in
                self.is_following = true
                self.followButton?.title = "Unfollow"
            })
        }
    }
    @IBAction func editAction(_ sender: Any) {
        if user.id == Me.user.id {
            if let navigator = navigationController {
                if(Me.user.avatar.characters.count > 0){
                    Me.img_avatar = self.imgAvatar.image
//                    Me.img_avatar = self.btnAvatar.backgroundImage(for: .normal)
                }
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                navigator.pushViewController(EditProfileViewController(), animated: true)
            }
        }
    }
    @IBAction func recipeListAction(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "recipeListVC") as? RecipeListViewController {
            if let navigator = navigationController {
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                viewController.user = self.user
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    @IBAction func followingAction(_ sender: Any) {
        let contactPickerScene = EPContactsPicker(subtitleCellType: SubtitleCellValue.email)
        contactPickerScene.is_following = true
        contactPickerScene.toUser = user
        navigationController?.pushViewController(contactPickerScene, animated: true)
    }
    @IBAction func followerAction(_ sender: Any) {
        let contactPickerScene = EPContactsPicker(subtitleCellType: SubtitleCellValue.email)
        contactPickerScene.is_following = false
        contactPickerScene.toUser = user
        navigationController?.pushViewController(contactPickerScene, animated: true)
    }
    func loadFromServer(){
        let currentIndexStr = String(format: "%d", currentIndex)
        NetworkManger.sharedInstance.profileAPIByIndex(parameters: [Constants.USER_ID_KEY : Me.user.id,
                                                                    Constants.USER_SESSION_KEY : Me.session_id,
                                                                    Constants.TOUSERID_KEY : user.id,
                                                                    Constants.INDEX_KEY : currentIndexStr]) { (jsonResponse, status) in
            if status == "1"{
                print(jsonResponse)
                let result = jsonResponse[Constants.RECIPE_KEY] as! [AnyObject]
                if self.user.id == Me.user.id {
                    if Me.user.avatar.characters.count > 0{
                        self.imgAvatar.af_setImage(withURL: URL(string: Me.user.avatar.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!)
                        self.imgAvatar.layer.cornerRadius = 40
                        self.imgAvatar.clipsToBounds = true
//                        self.btnAvatar.af_setBackgroundImage(for: UIControlState.normal, url: URL(string: Me.user.avatar)!)
                        
//                        self.btnAvatar.layer.cornerRadius = 40
//                        self.btnAvatar.clipsToBounds = true
                    }
                }else{
                    let profile = jsonResponse[Constants.PROFILE_KEY] as! [String : AnyObject]
                    if let profile_picture = profile[Constants.PICTURE_KEY] as? String {
                        if profile_picture.characters.count > 0 {
                            self.imgAvatar.af_setImage(withURL: URL(string: profile_picture.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!)
                            self.imgAvatar.layer.cornerRadius = 40
                            self.imgAvatar.clipsToBounds = true
//                            self.btnAvatar.af_setBackgroundImage(for: UIControlState.normal, url: URL(string: profile_picture)!)
//                            
//                            self.btnAvatar.layer.cornerRadius = 40
//                            self.btnAvatar.clipsToBounds = true
                        }
                    }
                }
                self.lblUsername.text = self.user.userName
                let follower = jsonResponse[Constants.FOLLOWER_KEY] as! String
                let following = jsonResponse[Constants.FOLLOWING_KEY] as! String
                let recipe_count = jsonResponse[Constants.RECIPE_COUNT_KEY] as! String
                
                self.lblRecipes.text = recipe_count
                self.lblFollowers.text = follower
                self.lblFollowing.text = following
                
                if result.count > 0 {
                    for recipe in result {
                        self.feedList.append(Recipe(dict: recipe as! NSDictionary))
                    }
                    self.collectionView.reloadData()
                }else{
                    //                        self.lblNoRecipePost.isHidden = false
                }
                let is_following_link = jsonResponse[Constants.IS_FOLLOW_KEY] as! String
                if is_following_link == "0"{
                    self.is_following = false
                    self.followButton?.title = "Follow"
                }else{
                    self.is_following = true
                    self.followButton?.title = "Unfollow"
                }
            }else {
                let alertController = UIAlertController(title: "ReciFoto", message: jsonResponse["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feedList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier, for: indexPath)
        
        if let cell = cell as? CollectionCell {
            
            let item = self.feedList[indexPath.row]
            cell.imageView.af_setImage(withURL: URL(string: item.imageURL)!)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
        
        return size
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipe = self.feedList[indexPath.row]
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "recipeVC") as? RecipeViewController {
            if let navigator = navigationController {
                viewController.recipe = recipe
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrolling = true
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrolling = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            if !self.scrolling {
                
            }
        })
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
