//
//  SearchUsersViewController
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class SearchUsersViewController: SearchViewController {
    
    var popularViewController:FollowingViewController?
    var outstandingQueries:[NSIndexPath:Bool] = [NSIndexPath:Bool]()
    var user:User?
    let plainCellHeight:CGFloat = 65
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "_User"
        self.textKey = "username"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 20
    }
    
    override func queryForTable() -> PFQuery {
        if searchTerm.isEmpty || searchTerm.stripWhitespace().isEmpty {
            return PFQuery()
        }
        
        let query = User.query()
        query!.whereKey("username", containsString: searchTerm.lowercaseString)
        return query!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.refreshControlBackground(Constants.primaryColorSoft)
        tableView.separatorInset = UIEdgeInsetsMake(68, 0, 0, 0)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        // Do any additional setup after loading the view.
    }
    
    override func objectsDidLoad(error: NSError?) {
        // If no results found default to popular page
        if (objects?.count == 0  && popularViewController == nil) {
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
        super.objectsDidLoad(error)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        UIApplication.sharedApplication().statusBarHidden = false
        tableView.reloadData()
        super.viewWillAppear(animated)
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
            let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! UserTableViewCell!
            if let user = object as? User {
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
        } else {
            // Should probably delete this default cell since we have the popular page show
            let cell = tableView.dequeueReusableCellWithIdentifier("PlainCell") as! PFTableViewCell!
            cell.textLabel?.textColor = UIColor(white: 0.8, alpha: 1)
            cell.textLabel?.text = "No results found..."
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if objects?.count == 0 {
        } else
        if let user = self.objectAtIndexPath(indexPath) as? User {
            if let story = user.currentStory {
                story.user = user
                delegate?.transitionToFeedWithStory(story, query: Queries.userStoriesQuery(user, exclude: nil))
            } else {
                delegate?.transitionToProfileWithUser(user)
            }
        }
    }
    
}
