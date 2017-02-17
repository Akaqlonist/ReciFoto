//
//  MyCollectionViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 2/15/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit
class MyCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var feedList: [DGProfileItem] = []
    fileprivate let kCellIdentifier = "Cell"
    fileprivate var scrolling = false
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "My Collection"
        
        collectionView?.register(SACollectionViewVerticalScalingCell.self, forCellWithReuseIdentifier: kCellIdentifier)
        
        guard let layout = collectionView?.collectionViewLayout as? SACollectionViewVerticalScalingFlowLayout else {
            return
        }
        
        layout.scaleMode = .hard
        layout.alphaMode = .easy
        layout.scrollDirection = .vertical
        
        var header: ESRefreshProtocol & ESRefreshAnimatorProtocol
        var footer: ESRefreshProtocol & ESRefreshAnimatorProtocol
        
        header = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
        footer = ESRefreshFooterAnimator.init(frame: CGRect.zero)
        self.collectionView?.es_addPullToRefresh(animator: header) { [weak self] in
            self?.refreshFeed()
        }
        self.collectionView?.es_addInfiniteScrolling(animator: footer) { [weak self] in
            self?.loadMore()
        }
        self.collectionView?.refreshIdentifier = String.init(describing: "default")
        self.collectionView?.expriedTimeInterval = 20.0
        
        self.collectionView?.es_startPullToRefresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func refreshFeed() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.feedList.removeAll()
            self.currentIndex = 0
            self.collectionAPIByIndex(index: self.currentIndex, didFinishedWithResult: { count in
                if count > 0 {
                    self.collectionView?.reloadData()
                }else{
                    
                }
                self.collectionView?.es_stopPullToRefresh()
            })
        }
    }
    
    private func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if self.currentIndex < 100{
                self.currentIndex += 10
                self.collectionAPIByIndex(index: self.currentIndex, didFinishedWithResult: { count in
                    if count > 0 {
                        self.collectionView?.reloadData()
                    }else{
                        
                    }
                })
                self.collectionView?.es_stopLoadingMore()
            }else{
                self.collectionView?.es_noticeNoMoreData()
            }
        }
    }
    func collectionAPIByIndex(index: Int, didFinishedWithResult: @escaping(Int) -> Void) -> Void{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getCollectionByIndex),
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
                            self.feedList.append(DGProfileItem(dict: recipe as! NSDictionary))
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
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(collectionView)
        return self.feedList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier, for: indexPath)
        
        if let cell = cell as? SACollectionViewVerticalScalingCell {
            
            let imageView = UIImageView(frame: cell.bounds)
            let item = self.feedList[indexPath.row]
            imageView.af_setImage(withURL: URL(string: item.imageURL)!)
            //            imageView.image = UIImage(named: "0\(number)")
            cell.containerView?.addSubview(imageView)
        }
        
        return cell
    }
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrolling = true
        
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrolling = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            if !self.scrolling {
                
            }
        })
    }
}
