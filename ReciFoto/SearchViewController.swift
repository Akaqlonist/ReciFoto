//
//  SearchViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/20/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var currentIndex = 0
    fileprivate let colors = [
        UIColor(red: 81     / 255.0,    green: 81      / 255.0,     blue: 79       / 255.0,     alpha: 1.0),
        UIColor(red: 242    / 255.0,    green: 94      / 255.0,     blue: 92       / 255.0,     alpha: 1.0),
        UIColor(red: 242    / 255.0,    green: 167     / 255.0,     blue: 92       / 255.0,     alpha: 1.0),
        UIColor(red: 229    / 255.0,    green: 201     / 255.0,     blue: 91       / 255.0,     alpha: 1.0),
        UIColor(red: 35     / 255.0,    green: 123     / 255.0,     blue: 160      / 255.0,     alpha: 1.0),
        UIColor(red: 81     / 255.0,    green: 81      / 255.0,     blue: 79       / 255.0,     alpha: 1.0),
        UIColor(red: 242    / 255.0,    green: 94      / 255.0,     blue: 92       / 255.0,     alpha: 1.0),
        UIColor(red: 242    / 255.0,    green: 167     / 255.0,     blue: 92       / 255.0,     alpha: 1.0),
        UIColor(red: 229    / 255.0,    green: 201     / 255.0,     blue: 91       / 255.0,     alpha: 1.0),
        UIColor(red: 35     / 255.0,    green: 123     / 255.0,     blue: 160      / 255.0,     alpha: 1.0),
        UIColor(red: 81     / 255.0,    green: 81      / 255.0,     blue: 79       / 255.0,     alpha: 1.0),
        UIColor(red: 242    / 255.0,    green: 94      / 255.0,     blue: 92       / 255.0,     alpha: 1.0)
    ]
    
    fileprivate var filteredNames: [AnyObject] = []
    
    fileprivate var names : [AnyObject] = []
    
    fileprivate var readyForPresentation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBarController?.navigationItem.title = "Search"
        self.filteredNames = self.names
        
        self.collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "SearchCollectionViewCell.identifier")
        self.collectionView.register(TextCollectionViewCell.self, forCellWithReuseIdentifier: "TextCollectionViewCell.identifier")
        
        if let collectionViewLayout = self.collectionView.collectionViewLayout as? RSKCollectionViewRetractableFirstItemLayout {
            
            collectionViewLayout.firstItemRetractableAreaInset = UIEdgeInsets(top: 8.0, left: 0.0, bottom: 8.0, right: 0.0)
        }
        if trendsAPI() == 1{
            
        }else{
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func trendsAPI() -> Int{
        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.getTrendsV2),
                                 method: .post, parameters: ["user_id" : Profile.user_id,
                                                             "session_id" : Profile.session_id,
                                                             "index" : index])
        
        apiRequest.responseString(completionHandler: { response in
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let status = jsonResponse[Constants.STATUS_KEY] as! String
                
                if status == "1"{
                    let result = jsonResponse[Constants.RESULT_KEY] as! [AnyObject]
                    if result.count > 0 {
                        self.names = result
                        self.filteredNames = self.names
                        
                        self.collectionView.reloadData()
                    }else{
                        
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
        
        switch indexPath.section {
            
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell.identifier", for: indexPath) as! SearchCollectionViewCell
            
            cell.searchBar.delegate = self
            cell.searchBar.searchBarStyle = .minimal
            cell.searchBar.placeholder = "Search - \(self.names.count) names"
            
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCollectionViewCell.identifier", for: indexPath) as! TextCollectionViewCell
            
            let name = self.filteredNames[indexPath.item] as! [String : String]
            
            cell.colorView.layer.cornerRadius = 10.0
            cell.colorView.layer.masksToBounds = true
            cell.colorView.backgroundColor = self.colors[indexPath.item]
            
            cell.label.textColor = UIColor.white
            cell.label.textAlignment = .center
            cell.label.text = name[Constants.RECIPE_TITLE_KEY]
            
            return cell
            
        default:
            assert(false)
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            return 1
            
        case 1:
            return self.filteredNames.count
            
        default:
            assert(false)
        }
    }
    
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        switch section {
            
        case 0:
            return UIEdgeInsets.zero
            
        case 1:
            return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
            
        default:
            assert(false)
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10.0
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10.0
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch indexPath.section {
            
        case 0:
            let itemWidth = collectionView.frame.width
            let itemHeight: CGFloat = 44.0
            
            return CGSize(width: itemWidth, height: itemHeight)
            
        case 1:
            let numberOfItemsInLine: CGFloat = 3
            
            let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
            let minimumInteritemSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
            
            let itemWidth = (collectionView.frame.width - inset.left - inset.right - minimumInteritemSpacing * (numberOfItemsInLine - 1)) / numberOfItemsInLine
            let itemHeight = itemWidth
            
            return CGSize(width: itemWidth, height: itemHeight)
            
        default:
            assert(false)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    internal func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        guard scrollView === self.collectionView else {
            
            return
        }
        
        let indexPath = IndexPath(item: 0, section: 0)
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? SearchCollectionViewCell else {
            
            return
        }
        
        guard cell.searchBar.isFirstResponder else {
            
            return
        }
        
        cell.searchBar.resignFirstResponder()
    }
    
    // MARK: - UISearchBarDelegate
    
    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let oldFilteredNames = self.filteredNames        
        if searchText.isEmpty {
            
            self.filteredNames = self.names
        }
        else {
            self.filteredNames = self.names.filter({
                if let subid = $0["recipe_title"] as? String {
                    return subid == searchText
                } else {
                    return false
                }
            })
        }
        
        self.collectionView.performBatchUpdates({
            
            for (oldIndex, oldName) in oldFilteredNames.enumerated() {
                do {
                    if try self.filteredNames.contains(where: oldName as! (AnyObject) throws -> Bool) == false {
                        
                        let indexPath = IndexPath(item: oldIndex, section: 1)
                        self.collectionView.deleteItems(at: [indexPath])
                    }
                }catch{
                    
                }
            }
            
            for (index, name) in self.filteredNames.enumerated() {
                do {
                    if try oldFilteredNames.contains(where: name as! (AnyObject) throws -> Bool) == false {
                    
                        let indexPath = IndexPath(item: index, section: 1)
                        self.collectionView.insertItems(at: [indexPath])
                    }
                }catch{
                    
                }
            }
            
        }, completion: nil)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
