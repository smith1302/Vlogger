//
//  ProfileTableViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/16/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class ProfileTableViewController: CustomPFQueryTableViewController {
    
    let user:User
    var fullMessageView:FullMessageView?
    var initialLoadCompleted = false
    
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
        storyQuery?.whereKey("active", equalTo: false)
        storyQuery?.orderByDescending("createdAt")
        storyQuery?.includeKey("video")
        return storyQuery!
    }
    
    override func objectsDidLoad(error: NSError?) {
        // If no results found default to popular page
        if objects?.count == 0  && fullMessageView == nil {
            fullMessageView = FullMessageView(frame: tableView.bounds, text: "No stories yet!")
            tableView.addSubview(fullMessageView!)
        } else if objects?.count > 0 {
            fullMessageView?.removeFromSuperview()
            fullMessageView = nil
        }
        initialLoadCompleted = true
        super.objectsDidLoad(error)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath?) -> PFObject? {
        if let indexPath = indexPath where indexPath.section == 0 {
            return user.currentStory
        }
        var newIndexPath = indexPath
        if let indexPath = indexPath {
            newIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
        }
        return super.objectAtIndexPath(newIndexPath)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 1)
        let label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor(white: 0.35, alpha: 1)
        label.font = UIFont.systemFontOfSize(14, weight: 0.2)
        if section == 0 {
            label.text = "Current Story"
        } else {
            label.text = "Previous Stories"
        }
        label.textAlignment = .Left
        view.addSubview(label)
        
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.9, alpha: 1)
        line.center.y = view.center.y
        view.addSubview(line)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        line.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 15))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: line, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: -15))
        view.addConstraint(NSLayoutConstraint(item: line, attribute: .Left, relatedBy: .Equal, toItem: label, attribute: .Right, multiplier: 1.0, constant: 15))
        view.addConstraint(NSLayoutConstraint(item: line, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: line, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1))
        
        return view
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell") as! ProfileTableViewCell!
        if let story = object as? Story {
            cell.configure(story, indexPath: indexPath)
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
                destinationVC.configureWithStory(story, user:self.user)
            }
        }
    }

}
