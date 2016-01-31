//
//  SettingsTableViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/31/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(white: 0.85, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        title = "Settings"
        self.navigationController?.navigationBarHidden = false
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath)
        if indexPath.row == 0 {
            cell.textLabel!.text = "Terms of Use"
        } else if indexPath.row == 1 && User.currentUser()!.notifications {
            cell.textLabel!.text = "Turn off notifications"
        } else if indexPath.row == 1 && !User.currentUser()!.notifications {
                cell.textLabel!.text = "Turn on notifications"
        } else {
            cell.textLabel!.text = "Log Out"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if indexPath.row == 0 {
                let storyboard = self.storyboard
                if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("TermsViewController") as? TermsViewController {
                    self.navigationController?.pushViewController(destinationVC, animated: true)
                }
            } else if indexPath.row == 1 && User.currentUser()!.notifications {
                PushController.unsubscribeToPush()
                cell.textLabel!.text = "Turn on notifications"
            } else if indexPath.row == 1 && !User.currentUser()!.notifications {
                PushController.subscribeToPush()
                cell.textLabel!.text = "Turn off notifications"
            } else {
                User.logOut()
                if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("IntroViewController") as? IntroViewController {
                    self.presentViewController(destinationVC, animated: true, completion: nil)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
