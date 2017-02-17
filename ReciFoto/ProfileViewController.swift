//
//  ProfileViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/20/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var feedList: [DGProfileItem] = []
    var currentIndex = 0
    var settingButton : UIBarButtonItem?//()
    var user_id = Profile.user_id
    var user_name = Profile.user_name
    
    fileprivate let kCellIdentifier = "Cell"
    fileprivate var scrolling = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblRecipes: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var lblUsername: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "My Profile"
        if user_id == Profile.user_id {
            var settingImage = UIImage(named: "gear")
            settingImage = settingImage?.withRenderingMode(.alwaysOriginal)
            settingButton = UIBarButtonItem(image: settingImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProfileViewController.settingAction))
            self.navigationItem.rightBarButtonItem = settingButton
        }
        loadFromServer()
        
        collectionView.register(SACollectionViewVerticalScalingCell.self, forCellWithReuseIdentifier: kCellIdentifier)
        
        guard let layout = collectionView.collectionViewLayout as? SACollectionViewVerticalScalingFlowLayout else {
            return
        }
        
        layout.scaleMode = .hard
        layout.alphaMode = .easy
        layout.scrollDirection = .vertical
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func settingAction(){
        self.performSegue(withIdentifier: "showSettings", sender: self)
    }
    func loadFromServer(){
        if profileAPIByIndex(index: currentIndex) == 1{
            
        }else{
            
        }
    }
    func profileAPIByIndex(index: Int) -> Int{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getProfileV2),
                                 method: .post, parameters: [Constants.USER_ID_KEY : Profile.user_id,
                                                             Constants.USER_SESSION_KEY : Profile.session_id,
                                                             Constants.TOUSERID_KEY : user_id,
                                                             Constants.INDEX_KEY : index])
        
        apiRequest.responseString(completionHandler: { response in
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]

                let status = jsonResponse[Constants.STATUS_KEY] as! String
                
                if status == "1"{
                    let result = jsonResponse[Constants.RECIPE_KEY] as! [AnyObject]
        
                    let profile = jsonResponse[Constants.PROFILE_KEY] as! [String : AnyObject]
                    print(profile)
                    if let profile_picture = profile[Constants.PICTURE_KEY] as? String {
                        if profile_picture.characters.count > 0 {
                            self.btnAvatar.af_setBackgroundImage(for: UIControlState.normal, url: URL(string: profile_picture)!)
                            self.btnAvatar.layer.cornerRadius = 40
                            self.btnAvatar.clipsToBounds = true
                        }
                    }
                    self.lblUsername.text = self.user_name
                    let follower = jsonResponse[Constants.FOLLOWER_KEY] as! String
                    let following = jsonResponse[Constants.FOLLOWING_KEY] as! String
                    let recipe_count = jsonResponse[Constants.RECIPE_COUNT_KEY] as! String
                    
                    self.lblRecipes.text = recipe_count
                    self.lblFollowers.text = follower
                    self.lblFollowing.text = following
                    
                    if result.count > 0 {
                        for recipe in result {
                            self.feedList.append(DGProfileItem(dict: recipe as! NSDictionary))
                        }
                        self.collectionView.reloadData()
                    }else{
                        //                        self.lblNoRecipePost.isHidden = false
                    }
                }else {
                    let alertController = UIAlertController(title: "ReciFoto", message: jsonResponse["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }catch{
                print("Error Parsing JSON from get_profile")
            }
            
        })
        
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(collectionView)
        return self.feedList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let tagNumber = 10001
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier, for: indexPath)
        
        if let cell = cell as? SACollectionViewVerticalScalingCell {
//            cell.containerView?.viewWithTag(tagNumber)?.removeFromSuperview()
            
            let imageView = UIImageView(frame: cell.bounds)
//            imageView.tag = tagNumber
            let item = self.feedList[indexPath.row] 
            imageView.af_setImage(withURL: URL(string: item.imageURL)!)
            //            imageView.image = UIImage(named: "0\(number)")
            cell.containerView?.addSubview(imageView)
        }
        
        return cell
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
