//
//  StoryUpdateFeedViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class StoryUpdateFeedViewController: CustomPFQueryTableViewController {
    
    var popularViewController:FollowingViewController?
    weak var delegate:TransitionToFeedDelegate?
    let plainCellHeight:CGFloat = 65
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "_User"
        self.textKey = "username"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 20
        self.loadingViewEnabled = false
    }
    
    func subscriptionQuery() -> PFQuery {
        let followQuery = Follow.query()
        followQuery?.whereKey("fromUser", equalTo: User.currentUser()!)
        
        let videoUpdatesQuery = Story.query()
        videoUpdatesQuery!.whereKey("user", matchesKey: "toUser", inQuery: followQuery!)
        videoUpdatesQuery!.whereKey("active", equalTo: true)
        videoUpdatesQuery!.orderByDescending("videoAddedAt")
        videoUpdatesQuery!.includeKey("user")
        
        videoUpdatesQuery!.orderByAscending("updatedAt")
        return videoUpdatesQuery!
    }
    
    /*
    *   Get the Users we are following
    */
    override func queryForTable() -> PFQuery {
        return subscriptionQuery()
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
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle = .None
        tableView.refreshControlBackground(Constants.primaryColorSoft)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func objectsWillLoad() {
        super.objectsWillLoad()
    }
    
    override func objectsDidLoad(error: NSError?) {
        // Special case to show popular update feed if theres no subscriptions
        if objects?.count == 0  && popularViewController == nil && error == nil {
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("FollowingViewController") as? FollowingViewController {
                vc.configure(Queries.popularQuery(), titleString: "Popular", headerString: "POPULAR USERS", noObjectsMessage: "No Users Found!")
                popularViewController = vc
                popularViewController?.delegate = delegate
                addChildViewController(vc)
                var finalFrame = self.tableView.bounds
                finalFrame.offsetInPlace(dx: 0, dy: plainCellHeight)
                finalFrame.size.height -= plainCellHeight
                let startFrame = vc.view.frame.offsetBy(dx: 0, dy: finalFrame.size.height)
                vc.view.frame = startFrame
                tableView.addSubview(vc.view)
                
                UIView.animateWithDuration(0.3, animations: {
                    vc.view.frame = finalFrame
                })
            }
        } else if objects?.count > 0 {
            popularViewController?.removeFromParentViewController()
            popularViewController?.view.removeFromSuperview()
            popularViewController = nil
        }
        // 103 means we just sent a blank PFQuery. Calling super on this stops the loading animation
        if error?.code != 103 {
            super.objectsDidLoad(error)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, super.tableView(tableView, numberOfRowsInSection: section))
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath?) -> PFObject? {
        if self.objects?.count > 0 { return super.objectAtIndexPath(indexPath) }
        return User()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if objectAtIndexPath(indexPath)?.objectId == nil {
            return plainCellHeight
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        if object?.objectId != nil {
            let cell = tableView.dequeueReusableCellWithIdentifier("StoryUpdateCell") as! StoryUpdateTableViewCell!
            if let story = object as? Story {
                cell.configureWithUser(story)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("PlainCell") as! PFTableViewCell!
            cell.textLabel?.textColor = UIColor(white: 0.8, alpha: 1)
            cell.textLabel?.text = "No recent updates..."
            return cell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if objects?.count == 0 {
            return
        }
        
        if let storyObjectFromCell = self.objectAtIndexPath(indexPath) as? Story {
            delegate?.transitionToFeedWithStory(storyObjectFromCell, user: storyObjectFromCell.user)
        }
    }
    
}
