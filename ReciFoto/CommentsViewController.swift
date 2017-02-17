//
//  CommentsViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 2/13/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit
class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentIndex = 0
    var commentsList: [Comment] = []
    var recipe_id = ""
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(white: 0.96, alpha: 1)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.allowsSelection = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Comments"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composePost))
        
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: String(describing: CommentTableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
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
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.es_startPullToRefresh()
    }
    private func refreshFeed() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.commentsList.removeAll()
            self.currentIndex = 0
            self.commentAPIByIndex(index: self.currentIndex, didFinishedWithResult: { count in
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
                self.commentAPIByIndex(index: self.currentIndex, didFinishedWithResult: { count in
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
    func commentAPIByIndex(index: Int, didFinishedWithResult: @escaping(Int) -> Void) -> Void{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getCommentsByIndexV2),
                                 method: .post, parameters: [Constants.USER_ID_KEY : Profile.user_id,
                                                             Constants.USER_SESSION_KEY : Profile.session_id,
                                                             Constants.RECIPE_ID_KEY : recipe_id,
                                                             Constants.INDEX_KEY : index])
        apiRequest.responseString(completionHandler: { response in
            do{
                print(response)
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                print(jsonResponse)
                if status == "1"{
                    if let result = jsonResponse[Constants.RESULT_KEY] as? [AnyObject]{
                        if result.count > 0 {
                            for comment in result {
                                self.commentsList.append(Comment(dict : comment as! NSDictionary))
                            }
                        }else{
                            //                        self.lblNoRecipePost.isHidden = false
                        }
                        didFinishedWithResult(result.count)
                    }else{
                        didFinishedWithResult(0)
                    }
                    
                }else {
                    didFinishedWithResult(0)
                    let alertController = UIAlertController(title: "ReciFoto", message: jsonResponse["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }catch{
                didFinishedWithResult(0)
                print("Error Parsing JSON from get_feed_by_index")
            }
            
        })
    }
    @objc private func composePost() {
        let vc = ComposeViewController()
        vc.recipe_id = recipe_id
        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CommentTableViewCell.self), for: indexPath) as! CommentTableViewCell
        let comment = commentsList[indexPath.row]
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
