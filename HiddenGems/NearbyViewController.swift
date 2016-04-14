//
//  NearbyViewController.swift
//  HiddenGems
//
//  Created by Wan Kim Mok on 4/1/16.
//  Copyright (c) 2016 Melissa Rojas. All rights reserved.
//

import UIKit

class NearbyViewController: UITableViewController {
    //let totalRows : Int = venueList.count as Int
    let totalRows : Int = exploreVenueList.count as Int
    
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.totalRows
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("venuesCell", forIndexPath: indexPath) as UITableViewCell
        /*
        cell.textLabel?.text = venueList[indexPath.row]["name"] as? String
        var location = venueList[indexPath.row]["location"] as NSDictionary
        cell.detailTextLabel?.text = location["address"] as? String
        var id = venueList[indexPath.row]["id"] as String
        //cell.imageView?.image = UIImage(named: "marker_red.png")
        //var data = imageCache[indexPath.row][
        cell.imageView?.image = UIImage(data: imageCache[id]!)
        */
        
        cell.textLabel?.text = (exploreVenueList[indexPath.row]["venue"] as NSDictionary)["name"] as? String
        var location = (exploreVenueList[indexPath.row]["venue"] as NSDictionary)["location"] as NSDictionary
        cell.detailTextLabel?.text = location["address"] as? String
        var id = (exploreVenueList[indexPath.row]["venue"] as NSDictionary)["id"] as String
        //cell.imageView?.image = UIImage(named: "marker_red.png")
        //var data = imageCache[indexPath.row][
        cell.imageView?.image = UIImage(data: exploreImageCache[id]!)
        
        return cell
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
