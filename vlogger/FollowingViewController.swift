//
//  FollowingViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class FollowingViewController: UserListViewController, UserTableViewCellDelegate {
    
    var fullMessageView:FullMessageView?
    
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
    
    override func objectsDidLoad(error: NSError?) {
        // If no results found default to popular page
        if objects?.count == 0  && fullMessageView == nil {
            fullMessageView = FullMessageView(frame: tableView.bounds, text: "No followers yet!")
            tableView.addSubview(fullMessageView!)
        } else if objects?.count > 0 {
            fullMessageView?.removeFromSuperview()
            fullMessageView = nil
        }
        super.objectsDidLoad(error)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Following"
        tableView.refreshControlBackground(Constants.primaryColorSoft)
        // Do any additional setup after loading the view.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> UserTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! UserTableViewCell!
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
                destinationVC.configureWithUser(user)
            }
        }
    }
    
    func cellActivated() {
        user?.followUser()
    }

}
