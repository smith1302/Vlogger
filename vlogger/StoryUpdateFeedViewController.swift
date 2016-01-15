//
//  StoryUpdateFeedViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class StoryUpdateFeedViewController: PFQueryTableViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "_User"
        self.textKey = "username"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 20
    }
    
    /*
    *   Get the Users we are following
    */
    override func queryForTable() -> PFQuery {
        
        // Get users that we follow
        let followQuery = Follow.query()
        followQuery?.whereKey("fromUser", equalTo: User.currentUser()!)
    
        let videoUpdatesQuery = VideoUpdates.query()
        videoUpdatesQuery!.whereKey("user", matchesKey: "toUser", inQuery: followQuery!)
        videoUpdatesQuery!.includeKey("user")
        videoUpdatesQuery!.includeKey("video")
        videoUpdatesQuery!.orderByAscending("updatedAt")
        return videoUpdatesQuery!
    }
    
    /*
        New class called VideoUpdates
        keys:
            User
            Video
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 55
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> StoryUpdateTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StoryUpdateCell") as! StoryUpdateTableViewCell!
        if let videoUpdate = object as? VideoUpdates {
            cell.configure(videoUpdate)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let videoUpdate = self.objectAtIndexPath(indexPath) as? VideoUpdates {
            let user = videoUpdate.user
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
