//
//  FollowingViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class FollowingViewController: CustomQueryTableViewController, UserTableViewCellDelegate {
    
    var fullMessageView:FullMessageView?
    var outstandingQueries:[NSIndexPath:Bool] = [NSIndexPath:Bool]()
    var user:User?
    var query:PFQuery?
    var titleString:String?
    var headerString:String?
    var noObjectsMessage:String = "None found!"
    weak var delegate:TransitionToFeedDelegate?
    
    func configure(query:PFQuery?, titleString:String, headerString:String?, noObjectsMessage:String) {
        self.query = query
        self.titleString = titleString
        self.headerString = headerString
        self.noObjectsMessage = noObjectsMessage
    }
    
    override func queryForTable() -> PFQuery {
        if query == nil {
            return PFQuery()
        }
        return query!
    }
    
    override func objectsDidLoad(error: NSError?) {
        // If no results found default to popular page
        if objects.count == 0  && fullMessageView == nil {
            fullMessageView = FullMessageView(frame: tableView.bounds, text: noObjectsMessage)
            tableView.addSubview(fullMessageView!)
        } else if objects.count > 0 {
            fullMessageView?.removeFromSuperview()
            fullMessageView = nil
        }
        super.objectsDidLoad(error)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = titleString
        tableView.refreshControlBackground(Constants.primaryColorSoft)
        tableView.estimatedRowHeight = 55
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorInset = UIEdgeInsetsMake(68, 0, 0, 0)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let title = headerString {
            let view = UIView()
            view.backgroundColor = UIColor(white: 1, alpha: 1)
            
            let header = UILabel()
            header.text = title
            header.textAlignment = .Left
            header.textColor = UIColor(white: 0.5, alpha: 1)
            header.frame = view.bounds
            header.font = UIFont.systemFontOfSize(16)
            view.addSubview(header)
            Utilities.autolayoutSubviewToViewEdges(header, view: view, edgeInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
            return view
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if headerString == nil {
            return 0
        }
        return 40
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UserTableViewCell {
        let object = objectAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! UserTableViewCell!
        var user:User?
        if let follow = object as? Follow {
            user = follow.fromUser
        } else if let assertedUser = object as? User {
            user = assertedUser
        }
        
        if let user = user {
            cell.configure(user)
            cell.delegate = self
            if outstandingQueries[indexPath] == nil && !user.isUs() {
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
        let object = self.objectAtIndexPath(indexPath)
        var user:User?
        if let follow = object as? Follow {
            user = follow.fromUser
        }  else if let assertedUser = object as? User {
            user = assertedUser
        }
        
        if let user = user {
            let storyboard = self.storyboard
            if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("FeedViewController") as? FeedViewController {
                self.navigationController?.pushViewController(destinationVC, animated: true)
                destinationVC.configureWithUser(user)
            }
            delegate?.transitionToFeed(user)
        }
    }
    
    func cellFollowed(user: User) {
        user.followUser()
    }
    
    func cellUnfollowed(user: User) {
        user.unfollowUser()
    }

}
