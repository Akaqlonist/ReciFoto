//
//  FeedViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/20/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit
class FeedViewController: UITableViewController {
    
    var feedList: [[DGFeedItem]] = []
    var jsonData: [DGFeedItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    func randomItem() -> DGFeedItem {
        let randomNumber: Int = Int(arc4random_uniform(UInt32(self.jsonData.count)))
        var item: DGFeedItem = self.jsonData[randomNumber]
        countDGFeedItemIdentifier += 1
        item.identifier = "unique-id-\(countDGFeedItemIdentifier)"
        return item
    }
    
    func inserRow() {
        if self.feedList.count == 0 {
            self.insertSection()
        } else {
            self.feedList[0].insert(self.randomItem(), at: 0)
            let indexPath: IndexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func insertSection() {
        self.feedList.insert([self.randomItem()], at: 0)
        self.tableView.insertSections(IndexSet(integer: 0), with: UITableViewRowAnimation.automatic)
    }
    
    func deleteSection() {
        if self.feedList.count > 0 {
            self.feedList.remove(at: 0)
            self.tableView.deleteSections(IndexSet(integer: 0), with: UITableViewRowAnimation.automatic)
        }
    }
    
    func insertRowsAtIndexPaths() {
        // demo 以section 0 为例子
        let section = 0
        if self.feedList.count == 0 {
            self.feedList.append([])
        }
        let lastIndex = self.feedList[section].count
        let insertItems = [self.randomItem(), self.randomItem(), self.randomItem(), self.randomItem(), self.randomItem()]
        for item in insertItems {
            self.feedList[section].append(item)
        }
        
        var indexPaths: [IndexPath] = []
        for index in 0..<insertItems.count {
            indexPaths.append(IndexPath(row: lastIndex + index, section: section))
        }
        
        self.tableView.beginUpdates()
        if self.tableView.numberOfSections < section + 1 {
            self.tableView.insertSections(IndexSet(integer: section), with: .automatic)
        } else {
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        }
        self.tableView.endUpdates()
    }
    
    func deleteRowsAtIndexPaths() {
        // demo 以section 0 为例子
        let section = 0
        guard self.feedList.count > section + 1 && self.feedList[section].count > 0 else { return }
        
        let row = self.feedList[section].count - 1
        let indexPath = IndexPath(row: row, section: section)
        self.feedList[section].removeLast()
        
        guard self.tableView.numberOfSections > section + 1 else { return }
        
        self.tableView.beginUpdates()
        if self.tableView.numberOfRows(inSection: section) > 1 {
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        } else {
            self.feedList.remove(at: section)
            self.tableView.deleteSections(IndexSet(integer: section), with: .automatic)
        }
        self.tableView.endUpdates()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.feedList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.feedList[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DGFeedCell = tableView.dequeueReusableCell(withIdentifier: "DGFeedCell", for: indexPath) as! DGFeedCell
        if indexPath.row % 2 == 0 {
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        cell.loadData(self.feedList[indexPath.section][indexPath.row])
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
extension FeedViewController{
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.feedList[indexPath.section].remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
}
