//
//  ProfileTableViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/16/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class ProfileTableViewController: PFQueryTableViewController {
    
    let user:User
    
    init(user:User, tableView:UITableView) {
        self.user = user
        super.init(style: UITableViewStyle.Plain, className: "Story")
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 55
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func queryForTable() -> PFQuery {
        // Get users that we follow
        let storyQuery = Story.query()
        storyQuery?.whereKey("user", equalTo: user)
        storyQuery?.orderByDescending("day")
        storyQuery?.includeKey("video")
        return storyQuery!
    }
    
    override func objectsWillLoad() {
        print("will load")
    }
    
    override func objectsDidLoad(error: NSError?) {
        print(error)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> ProfileTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell") as! ProfileTableViewCell!
        if let story = object as? Story {
            cell.configure(story)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let story = self.objectAtIndexPath(indexPath) as? Story {
            let storyboard = self.parentViewController?.storyboard
            if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("FeedViewController") as? FeedViewController {
                self.navigationController?.pushViewController(destinationVC, animated: true)
                // We already have user downloaded in this case so lets just pass it off
                story.user = self.user
                destinationVC.configureWithStory(story)
            }
        }
    }

}
