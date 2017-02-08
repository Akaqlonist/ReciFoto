//
//  ProfileViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/20/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var feedList: [DGProfileItem] = []
    var currentIndex = 0
    @IBOutlet weak var lblRecipes: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var btnAvatar: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBarController?.navigationItem.title = "My Profile"
        loadFromServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFromServer(){
        if profileAPIByIndex(index: currentIndex) == 1{
            
        }else{
            
        }
    }
    func profileAPIByIndex(index: Int) -> Int{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getProfileV2),
                                 method: .post, parameters: ["user_id" : Profile.user_id,
                                                             "session_id" : Profile.session_id,
                                                             "user_name": Profile.user_name,
                                                             "index" : index])
        
        apiRequest.responseString(completionHandler: { response in
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                
                if status == "1"{
                    let result = jsonResponse[Constants.RECIPE_KEY] as! [AnyObject]
        
                    let profile = jsonResponse[Constants.PROFILE_KEY] as! [String : AnyObject]
                    print(profile)
                    let profile_picture = profile[Constants.PICTURE_KEY] as! String
                    if profile_picture.characters.count > 0 {
                        self.btnAvatar.af_setBackgroundImage(for: UIControlState.normal, url: URL(string: profile_picture)!)
                        self.btnAvatar.layer.cornerRadius = 40
                        self.btnAvatar.clipsToBounds = true
                    }
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
                        self.tableView.reloadData()
                    }else{
                        //                        self.lblNoRecipePost.isHidden = false
                    }
                }else {
                    let alertController = UIAlertController(title: "ReciFoto", message: jsonResponse["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }catch{
                print("Error Parsing JSON from get_feed_by_index")
            }
            
        })
        
        return 1
    }
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.feedList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DGProfileCell = tableView.dequeueReusableCell(withIdentifier: "DGProfileCell", for: indexPath) as! DGProfileCell
        cell.loadData(self.feedList[indexPath.row])
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
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
