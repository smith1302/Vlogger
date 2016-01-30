//
//  SearchUsersViewController
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class SearchStoriesViewController: SearchViewController {
    
    var outstandingQueries:[NSIndexPath:Bool] = [NSIndexPath:Bool]()
    var user:User?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Story"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 20
    }
    
    override func queryForTable() -> PFQuery {
        if searchTerm.isEmpty || searchTerm.stripWhitespace().isEmpty {
            return PFQuery()
        }
        
        let query = Story.query()
        query!.whereKey("tags", equalTo: searchTerm.lowercaseString)
        query!.whereKey("videoCount", greaterThanOrEqualTo: 1)
        query!.includeKey("user")
        query!.includeKey("video")
        return query!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        tableView.estimatedRowHeight = 55
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.refreshControlBackground(Constants.primaryColorSoft)
        // Do any additional setup after loading the view.
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
            let cell = tableView.dequeueReusableCellWithIdentifier("TrendingCell") as! ExpandedStoryTableViewCell!
            if let story = object as? Story {
                cell.configure(story)
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
        } else if let story = self.objectAtIndexPath(indexPath) as? Story {
            let user = story.user
            delegate?.transitionToFeedWithStory(story, user: user)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if objectAtIndexPath(indexPath)?.objectId == nil {
            return 55
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
}
