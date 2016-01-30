//
//  StoryUpdateFeedViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

enum StoryUpdateFeedType {
    case subscriptions
    case popular
}

class StoryUpdateFeedViewController: CustomPFQueryTableViewController {
    
    var popularViewController:StoryUpdateFeedViewController?
    var query:PFQuery?
    var feedType:StoryUpdateFeedType!
    var headerTitle:String?
    weak var delegate:TransitionToFeedDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "_User"
        self.textKey = "username"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 20
        self.loadingViewEnabled = false
    }
    
    func configureWithFeedType(type:StoryUpdateFeedType, headerTitle:String? = nil) {
        feedType = type
        if type == StoryUpdateFeedType.popular {
            self.showLoader = false
            self.query = popularQuery()
        } else {
            self.query = subscriptionQuery()
        }
        self.headerTitle = headerTitle
        loadObjects()
    }
    
    func popularQuery() -> PFQuery {
        let query = User.query()
        query?.orderByDescending("subscriberCount")
        query?.limit = 5
        return query!
    }
    
    func subscriptionQuery() -> PFQuery {
        let followQuery = Follow.query()
        followQuery?.whereKey("fromUser", equalTo: User.currentUser()!)
        
        let videoUpdatesQuery = Story.query()
        videoUpdatesQuery!.whereKey("user", matchesKey: "toUser", inQuery: followQuery!)
        videoUpdatesQuery!.whereKey("active", equalTo: true)
        videoUpdatesQuery!.orderByDescending("videoAddedAt")
        videoUpdatesQuery!.includeKey("user")
        videoUpdatesQuery!.includeKey("video")
        
        videoUpdatesQuery!.orderByAscending("updatedAt")
        return videoUpdatesQuery!
    }
    
    /*
    *   Get the Users we are following
    */
    override func queryForTable() -> PFQuery {
        return query == nil ? PFQuery() : query!
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
        if objects?.count == 0  && popularViewController == nil && feedType == StoryUpdateFeedType.subscriptions && query != nil && error == nil {
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("StoryUpdateFeedViewController") as? StoryUpdateFeedViewController {
                vc.delegate = delegate
                popularViewController = vc
                addChildViewController(vc)
                vc.view.frame = self.tableView.bounds
                tableView.addSubview(vc.view)
                //Utilities.autolayoutSubviewToViewEdges(vc.view, view: self.view)
                vc.configureWithFeedType(StoryUpdateFeedType.popular, headerTitle: "No subscripton updates to show")
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let title = headerTitle {
            let view = UIView()
            view.backgroundColor = UIColor(white: 1, alpha: 1)
            let header = UILabel()
            header.text = title
            header.textAlignment = .Left
            header.textColor = UIColor(white: 0.7, alpha: 1)
            header.frame = view.bounds
            view.addSubview(header)
            Utilities.autolayoutSubviewToViewEdges(header, view: view, edgeInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
            return view
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if headerTitle == nil {
            return 0
        }
        return 55
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> StoryUpdateTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StoryUpdateCell") as! StoryUpdateTableViewCell!
        if let videoUpdate = object as? VideoUpdates {
            cell.configureWithVideoUpdate(videoUpdate)
        } else if let user = object as? User {
            cell.configureWithUser(user)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var user:User?
        if let videoUpdate = self.objectAtIndexPath(indexPath) as? VideoUpdates {
            user = videoUpdate.user
        } else if let userObjectFromCell = self.objectAtIndexPath(indexPath) as? User {
            user = userObjectFromCell
        }
        
        if let user = user {
            delegate?.transitionToFeed(user)
        }
    }
    
}
