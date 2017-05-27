//
//  RecipeListViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 3/1/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class RecipeListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var lblNoResult: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var currentIndex = 0
    var user : User = User()
    fileprivate var names : [Recipe] = []
    
    fileprivate var readyForPresentation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        self.navigationItem.title = "Recipes"
        let titleButton =  UIButton(type: .custom)
        titleButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleButton.backgroundColor = UIColor.clear
        titleButton.setTitle("Recipes", for: .normal)
        titleButton.addTarget(self, action: #selector(self.clickOnTitleButton), for: .touchUpInside)
        self.navigationItem.titleView = titleButton
        
        self.collectionView.register(TextCollectionViewCell.self, forCellWithReuseIdentifier: "TextCollectionViewCell.identifier")
        
        if let collectionViewLayout = self.collectionView.collectionViewLayout as? RSKCollectionViewRetractableFirstItemLayout {
            collectionViewLayout.firstItemRetractableAreaInset = UIEdgeInsets(top: 8.0, left: 0.0, bottom: 8.0, right: 0.0)
        }
        self.lblNoResult.isHidden = true
        self.collectionView.es_addPullToRefresh {
            self.currentIndex = 0
            self.refreshActivity()
        }
        self.collectionView.es_startPullToRefresh()
        self.collectionView.es_addInfiniteScrolling {
            self.loadMore()
        }
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
    private func refreshActivity() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.names.removeAll()
            self.currentIndex = 0
            self.feedAPIByIndex(index: self.currentIndex, didFinishedWithResult: { count in
                if count > 0 {
                    self.collectionView.reloadData()
                }else{
                    
                }
                self.collectionView.es_stopPullToRefresh()
            })
        }
    }
    
    private func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if self.currentIndex < 100{
                self.currentIndex += 10
                self.feedAPIByIndex(index: self.currentIndex, didFinishedWithResult: { count in
                    if count > 0 {
                        self.collectionView.reloadData()
                    }else{
                        
                    }
                })
                self.collectionView.es_stopLoadingMore()
            }else{
                self.collectionView.es_noticeNoMoreData()
            }
        }
    }

    func feedAPIByIndex(index: Int, didFinishedWithResult: @escaping(Int) -> Void) -> Void{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getUserRecipesV2),
                                 method: .post, parameters: [Constants.USER_ID_KEY : Me.user.id,
                                                             Constants.USER_SESSION_KEY : Me.session_id,
                                                             Constants.TOUSERID_KEY: self.user.id,
                                                             Constants.INDEX_KEY : self.currentIndex])
        
        apiRequest.responseString(completionHandler: { response in
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                
                if status == "1"{
                    let result = jsonResponse[Constants.RESULT_KEY] as! [AnyObject]
                    if result.count > 0 {
                        for recipe in result {
                            self.names.append(Recipe(dict: recipe as! NSDictionary))
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
                }
            }catch{
                didFinishedWithResult(0)
                print("Error Parsing JSON from get_feed_by_index")
            }
            
        })
    }
    // MARK: - Layout
    
    internal override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        guard self.readyForPresentation == false else {
            
            return
        }
        
        self.readyForPresentation = true
        
        let searchItemIndexPath = IndexPath(item: 0, section: 0)
        self.collectionView.contentOffset = CGPoint(x: 0.0, y: self.collectionView(self.collectionView, layout: self.collectionView.collectionViewLayout, sizeForItemAt: searchItemIndexPath).height)
    }
    
    // MARK: - UICollectionViewDataSource
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCollectionViewCell.identifier", for: indexPath) as! TextCollectionViewCell
        cell.colorView.alpha = 1
        cell.imageView.alpha = 0
        cell.colorView.layer.cornerRadius = 10.0
        cell.colorView.layer.masksToBounds = true
        cell.label.textColor = UIColor.white
        cell.label.textAlignment = .center
        
        
        let recipe = self.names[indexPath.item]
        
        cell.colorView.backgroundColor = Constants.colors[indexPath.item % 12]
        
        cell.label.text = recipe.title
        
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipe = self.names[indexPath.item]
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "recipeVC") as? RecipeViewController {
            if let navigator = navigationController {
                viewController.recipe = recipe
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.names.count
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 5.0
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 5.0
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsInLine: CGFloat = 3
        
        let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let minimumInteritemSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
        
        let itemWidth = (collectionView.frame.width - inset.left - inset.right - minimumInteritemSpacing * (numberOfItemsInLine - 1)) / numberOfItemsInLine
        let itemHeight = itemWidth
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}

