//
//  TrendingViewController
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class TrendingViewController: PFQueryTableViewController {
    
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
        let storyQuery = Story.query()
        storyQuery?.whereKey("createdAt", greaterThan: NSDate(timeIntervalSinceNow: -60*60*24*7))
        storyQuery?.orderByDescending("views")
        storyQuery?.includeKey("user")
        storyQuery?.includeKey("video")
        return storyQuery!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 55
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> TrendingTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrendingCell") as! TrendingTableViewCell!
        if let story = object as? Story {
            cell.configure(story)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view =  UIView(frame: CGRectMake(0,0,tableView.frame.size.width,10))
        view.backgroundColor = UIColor.whiteColor()
        return view
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let story = self.objectAtIndexPath(indexPath) as? Story {
            let user = story.user
            let storyboard = self.storyboard
            if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("FeedViewController") as? FeedViewController {
                self.navigationController?.pushViewController(destinationVC, animated: true)
                destinationVC.configureWithUser(user)
            }
        }
    }
    
}
