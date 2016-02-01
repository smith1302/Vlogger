//
//  TrendingViewController
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class TrendingViewController: CustomQueryTableViewController {
    
    var fullMessageView:FullMessageView?
    weak var delegate:TransitionToFeedDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    *   Get the Users we are following
    */
    override func queryForTable() -> PFQuery {
        
        // Get users that we follow
        let storyQuery = Story.query()
        storyQuery?.whereKey("videoAddedAt", greaterThan: NSDate(timeIntervalSinceNow: -60*60*24*7))
        //storyQuery?.whereKey("active", equalTo: true)
        storyQuery?.orderByDescending("featured")
        storyQuery?.whereKey("videoCount", greaterThanOrEqualTo: 1)
        storyQuery?.addDescendingOrder("views")
        storyQuery?.includeKey("user")
        storyQuery?.includeKey("video")
        return storyQuery!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 55
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.refreshControlBackground(Constants.primaryColorSoft)
    }
    
    override func objectsDidLoad(error: NSError?) {
        // If no results found default to popular page
        if objects.count == 0  && fullMessageView == nil {
            fullMessageView = FullMessageView(frame: tableView.bounds, text: "No stories yet!")
            tableView.addSubview(fullMessageView!)
        } else if objects.count > 0 {
            fullMessageView?.removeFromSuperview()
            fullMessageView = nil
        }
        super.objectsDidLoad(error)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> ExpandedStoryTableViewCell {
        let object = self.objectAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier("TrendingCell") as! ExpandedStoryTableViewCell!
        if let story = object as? Story {
            cell.configure(story.getCached())
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let story = self.objectAtIndexPath(indexPath) as? Story {
            let user = story.user
            delegate?.transitionToFeedWithStory(story, user: user)
        }
    }
    
}
