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
    var user:User?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "_User"
        self.textKey = "username"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 20
    }
    
    override func queryForTable() -> PFQuery {
        if user == nil {
            return PFQuery()
        }
        
        // Get users following targetUser
        let query = Follow.query()
        query!.whereKey("toUser", equalTo: user!)
        query!.includeKey("fromUser")
        return query!
    }
    
    func configure(user:User) {
        self.user = user
        self.loadObjects()
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
        title = "Following"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        UIApplication.sharedApplication().statusBarHidden = false
        tableView.reloadData()
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> FollowingTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell!
        if let follow = object as? Follow {
            let user = follow.fromUser
            cell.configure(user)
            if outstandingQueries[indexPath] == nil {
                outstandingQueries[indexPath] = true
                User.currentUser()!.isFollowingUser(user, callback: {
                    (isFollowing:Bool) in
                    cell.setFollow(isFollowing, enabled: true)
                    self.outstandingQueries.removeValueForKey(indexPath)
                })
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let follow = self.objectAtIndexPath(indexPath) as? Follow {
            let user = follow.fromUser
            let storyboard = self.storyboard
            if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("FeedViewController") as? FeedViewController {
                self.navigationController?.pushViewController(destinationVC, animated: true)
                destinationVC.configure(user)
            }
        }
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
