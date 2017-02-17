//
//  FeedViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/20/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit
class FeedViewController: UITableViewController {
    
    var feedList: [DGFeedItem] = []
    var currentIndex = 0
    
    @IBOutlet weak var lblNoRecipePost: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //Set Title
        self.navigationItem.title = "Public Recipe List"
        
        var header: ESRefreshProtocol & ESRefreshAnimatorProtocol
        var footer: ESRefreshProtocol & ESRefreshAnimatorProtocol
        
        header = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
        footer = ESRefreshFooterAnimator.init(frame: CGRect.zero)
        self.tableView.es_addPullToRefresh(animator: header) { [weak self] in
            self?.refreshFeed()
        }
        self.tableView.es_addInfiniteScrolling(animator: footer) { [weak self] in
            self?.loadMore()
        }
        self.tableView.refreshIdentifier = String.init(describing: "default")
        self.tableView.expriedTimeInterval = 20.0
        
        self.tableView.es_startPullToRefresh()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func refreshFeed() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.feedList.removeAll()
            self.currentIndex = 0
            self.feedAPIByIndex(index: self.currentIndex, didFinishedWithResult: { count in
                if count > 0 {
                    self.tableView.reloadData()
                }else{
                    
                }
                self.tableView.es_stopPullToRefresh()
            })
        }
    }
    
    private func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if self.currentIndex < 100{
                self.currentIndex += 10
                self.feedAPIByIndex(index: self.currentIndex, didFinishedWithResult: { count in
                    if count > 0 {
                        self.tableView.reloadData()
                    }else{
                        
                    }
                })
                self.tableView.es_stopLoadingMore()
            }else{
                self.tableView.es_noticeNoMoreData()
            }
        }
    }
    func feedAPIByIndex(index: Int, didFinishedWithResult: @escaping(Int) -> Void) -> Void{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getFeedByIndex),
                                 method: .post, parameters: [Constants.USER_ID_KEY : Profile.user_id,
                                                             Constants.USER_SESSION_KEY : Profile.session_id,
                                                             Constants.INDEX_KEY : index])
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                print(jsonResponse)
                if status == "1"{
                    let result = jsonResponse[Constants.RESULT_KEY] as! [AnyObject]
                    if result.count > 0 {
                        for recipe in result {
                            self.feedList.append(DGFeedItem(dict: recipe as! NSDictionary))
                        }
                        
                    }else{
//                        self.lblNoRecipePost.isHidden = false
                    }
                    didFinishedWithResult(result.count)
                }else {
                    didFinishedWithResult(0)
                    let alertController = UIAlertController(title: "ReciFoto", message: jsonResponse["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    appDelegate.setHasLoginInfo(status: false)
                    appDelegate.saveToUserDefaults()
                    
                    appDelegate.changeRootViewController(with: "loginNavigationVC")
                }
            }catch{
                didFinishedWithResult(0)
                print("Error Parsing JSON from get_feed_by_index")
            }
            
        })
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.feedList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DGFeedCell = tableView.dequeueReusableCell(withIdentifier: "DGFeedCell", for: indexPath) as! DGFeedCell
        cell.delegate = self
        cell.loadData(self.feedList[indexPath.row])
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell 
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension FeedViewController : DGFeedCellDelegaete{
    func didLikeWithItem(item: DGFeedItem) {
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.recipeLikeV2),
                                 method: .post, parameters: [Constants.USER_ID_KEY : Profile.user_id,
                                                             Constants.USER_SESSION_KEY : Profile.session_id,
                                                             Constants.RECIPE_ID_KEY : item.identifier])
        
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
    func didMoreWithItem(item: DGFeedItem) {

        let actionSheetController = UIAlertController(title: "ReciFoto", message: "Choose your action", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Save to Collection", style: .default) { action -> Void in
            print("Save")
            let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.saveCollection),
                                     method: .post, parameters: [Constants.USER_ID_KEY : Profile.user_id,
                                                                 Constants.USER_SESSION_KEY : Profile.session_id,
                                                                 Constants.RECIPE_ID_KEY : item.identifier])
            print(Profile.user_id)
            print(Profile.session_id)
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
                                     method: .post, parameters: [Constants.USER_ID_KEY : Profile.user_id,
                                                                 Constants.USER_SESSION_KEY : Profile.session_id,
                                                                 Constants.RECIPE_ID_KEY : item.identifier])
            print(Profile.user_id)
            print(Profile.session_id)
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
    func didCommentWithItem(item: DGFeedItem) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "commentsVC") as? CommentsViewController {
            if let navigator = navigationController {
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                viewController.recipe_id = item.identifier
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    func didProfileWithItem(item: DGFeedItem) {
        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController {
            if let navigator = navigationController {
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                viewController.user_id = item.user_id
                viewController.user_name = item.userName
                navigator.pushViewController(viewController, animated: true)
            }
        }
        
    }
}
