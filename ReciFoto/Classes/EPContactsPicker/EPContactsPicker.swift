//
//  EPContactsPicker.swift
//  EPContacts
//
//  Created by Prabaharan Elangovan on 12/10/15.
//  Copyright © 2015 Prabaharan Elangovan. All rights reserved.
//

import UIKit


typealias ContactsHandler = (_ contacts : [User] , _ error : NSError?) -> Void

public enum SubtitleCellValue{
    case userName
    case phoneNumber
    case email
    case birthday
}

open class EPContactsPicker: UITableViewController {
    
    // MARK: - Properties
    var is_following : Bool = true
    var toUser : User = User()
    var contactsList = [User]()
    
    var subtitleCellValue = SubtitleCellValue.userName
    
    // MARK: - Lifecycle Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        if is_following{
            self.title = EPGlobalConstants.Strings.followingTitle
        }else{
            self.title = EPGlobalConstants.Strings.followerTitle
        }

        registerContactCell()
        reloadContacts()
    }
    
    fileprivate func registerContactCell() {
        
        let podBundle = Bundle(for: self.classForCoder)
        if let bundleURL = podBundle.url(forResource: EPGlobalConstants.Strings.bundleIdentifier, withExtension: "bundle") {
            
            if let bundle = Bundle(url: bundleURL) {
                
                let cellNib = UINib(nibName: EPGlobalConstants.Strings.cellNibIdentifier, bundle: bundle)
                tableView.register(cellNib, forCellReuseIdentifier: "Cell")
            }
            else {
                assertionFailure("Could not load bundle")
            }
        }
        else {
            
            let cellNib = UINib(nibName: EPGlobalConstants.Strings.cellNibIdentifier, bundle: nil)
            tableView.register(cellNib, forCellReuseIdentifier: "Cell")
        }
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Initializers
  
    convenience public init(subtitleCellType: SubtitleCellValue) {
        self.init(style: .plain)
        subtitleCellValue = subtitleCellType
    }
    
    
    // MARK: - Contact Operations
  
      open func reloadContacts() {
        getContacts( {(contacts, error) in
            if (error == nil) {
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        })
      }
  
    func getContacts(_ completion:  @escaping ContactsHandler) {
        let parameters = [Constants.USER_ID_KEY : Me.user.id,
                          Constants.USER_SESSION_KEY : Me.session_id,
                          Constants.TOUSERID_KEY : toUser.id]
        if is_following{
            NetworkManger.sharedInstance.getFollowigsAPI(parameters: parameters, completionHandler: { (jsonResponse, status) in
                if status == "1"{
                    let result = jsonResponse[Constants.RESULT_KEY] as! [AnyObject]
                    if result.count > 0{
                        for user in result {
                            self.contactsList.append(User(dict: user as! NSDictionary))
                        }
                    }else{
                        
                    }
                    completion(self.contactsList, nil)
                }else{
                    
                }
            })
        }else{
            NetworkManger.sharedInstance.getFollowersAPI(parameters: parameters, completionHandler: { (jsonResponse, status) in
                if status == "1"{
                    let result = jsonResponse[Constants.RESULT_KEY] as! [AnyObject]
                    if result.count > 0{
                        for user in result {
                            self.contactsList.append(User(dict: user as! NSDictionary))
                        }
                    }else{
                        
                    }
                    completion(self.contactsList, nil)
                }else{
                    
                }
            })
        }
    }
    
    // MARK: - Table View DataSource
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactsList.count
    }

    // MARK: - Table View Delegates

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EPContactCell
        cell.accessoryType = UITableViewCellAccessoryType.none
        //Convert User to EPContact
		let contact = self.contactsList[(indexPath as NSIndexPath).row]
		
        cell.updateContactsinUI(contact, indexPath: indexPath, subtitleType: .userName)
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! EPContactCell
        let selectedContact =  cell.contact!
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController {
            if let navigator = navigationController {
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                viewController.user = selectedContact
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
