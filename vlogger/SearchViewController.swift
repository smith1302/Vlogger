//
//  FollowingViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class SearchViewController: UserListViewController {
    
    var searchTerm:String = ""
    
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
        title = "Search"
        // Do any additional setup after loading the view.
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
            let cell = tableView.dequeueReusableCellWithIdentifier("PlainCell") as! PFTableViewCell!
            cell.textLabel?.textColor = UIColor(white: 0.8, alpha: 1)
            cell.textLabel?.text = "No results found"
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if objects?.count == 0 {
        } else
        if let user = self.objectAtIndexPath(indexPath) as? User {
            let storyboard = self.storyboard
            if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("FeedViewController") as? FeedViewController {
                self.navigationController?.pushViewController(destinationVC, animated: true)
                destinationVC.configureWithUser(user)
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if objectAtIndexPath(indexPath)?.objectId == nil {
            return 55
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    func doSearch(searchTerm:String?) {
        if let text = searchTerm {
            self.searchTerm = text
        } else {
            self.searchTerm = ""
        }
        loadObjects()
    }
    
}
