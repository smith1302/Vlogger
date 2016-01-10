//
//  FollowingViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class FollowingViewController: PFQueryTableViewController {
    
    var outstandingQueries:[NSIndexPath:Bool] = [NSIndexPath:Bool]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "_User"
        self.textKey = "username"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 20
    }
    
    override func queryForTable() -> PFQuery {
        // Get users following targetUser
        let query = Follow.query()
        query!.whereKey("toUser", equalTo: User.currentUser()!)
        return query!
    }
    
//    override func objectsDidLoad(error: NSError?) {
//        super.objectsDidLoad(error)
//        // Get users we are following in objects
//        let query = Follow.query()
//        query!.whereKey("fromUser", equalTo: User.currentUser()!)
//        query!.whereKey("toUser", containedIn: self.objects!)
//        query!.cachePolicy = .NetworkOnly
//        
//    }
    
    // Get all users following "targetUser"
    // Check to see if we are following those users

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarHidden = false
        title = "Following"
        // Do any additional setup after loading the view.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> FollowingTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell!
        if let user = object as? User {
            cell.configure(user)
            if outstandingQueries[indexPath] == nil {
                outstandingQueries[indexPath] = true
                let query = Follow.query()
                query!.whereKey("fromUser", equalTo: User.currentUser()!)
                query!.whereKey("toUser", equalTo: user)
                query!.cachePolicy = .CacheThenNetwork
                query!.countObjectsInBackgroundWithBlock({
                    (count:Int32, error:NSError?) in
                    if count > 0 {
                        self.outstandingQueries.removeValueForKey(indexPath)
                        cell.followUser()
                    }
                })
            }
        }
        return cell
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let destinationVC:ShowImagesViewController = segue.destinationViewController as? ShowImagesViewController {
//            let indexPath = self.tableView.indexPathForSelectedRow;
//            if let object = self.objects?[indexPath!.row] as? PFUser {
//                destinationVC.specificUser = object
//            }
//            tableView.deselectRowAtIndexPath(indexPath!, animated: true);
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
