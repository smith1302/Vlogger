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
    
    var popularViewController:StoryUpdateFeedViewController?
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
        tableView.separatorStyle = .None
        tableView.refreshControlBackground(Constants.primaryColorSoft)
        // Do any additional setup after loading the view.
    }
    
    override func objectsDidLoad(error: NSError?) {
        // If no results found default to popular page
        if objects?.count == 0  && popularViewController == nil {
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("StoryUpdateFeedViewController") as? StoryUpdateFeedViewController {
                vc.delegate = delegate
                popularViewController = vc
                addChildViewController(vc)
                vc.view.frame = self.tableView.bounds
                tableView.addSubview(vc.view)
                //Utilities.autolayoutSubviewToViewEdges(vc.view, view: self.view)
                vc.configureWithFeedType(StoryUpdateFeedType.popular, headerTitle: "No results found")
                return
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
        let count = super.tableView(tableView, numberOfRowsInSection: section)
        return max(count,1)
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath?) -> PFObject? {
        if self.objects?.count > 0 { return super.objectAtIndexPath(indexPath) }
        return User()
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
            cell.textLabel?.text = ""
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if objects?.count == 0 {
        } else
        if let user = self.objectAtIndexPath(indexPath) as? User {
            delegate?.transitionToFeed(user)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if objectAtIndexPath(indexPath)?.objectId == nil {
            return 55
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
}
