//
//  ActivityViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/20/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class ActivityViewController: UITableViewController {
    var feedList: [DGFeedItem] = []
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBarController?.navigationItem.title = "My Recipes"
        loadFromServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFromServer(){
        if feedAPIByIndex(index: currentIndex) == 1{
            
        }else{
            
        }
    }
    func feedAPIByIndex(index: Int) -> Int{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getUserRecipesV2),
                                 method: .post, parameters: ["user_id" : Profile.user_id,
                                                             "session_id" : Profile.session_id,
                                                             "user_name": Profile.user_name,
                                                             "index" : index])
        
        apiRequest.responseString(completionHandler: { response in
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                
                if status == "1"{
                    let result = jsonResponse[Constants.RESULT_KEY] as! [AnyObject]
                    if result.count > 0 {
                        for recipe in result {
                            self.feedList.append(DGFeedItem(dict: recipe as! NSDictionary))
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.feedList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DGFeedCell = tableView.dequeueReusableCell(withIdentifier: "DGFeedCell", for: indexPath) as! DGFeedCell
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
