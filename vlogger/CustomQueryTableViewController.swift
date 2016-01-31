//
//  CustomQueryTableViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/31/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class CustomQueryTableViewController: UITableViewController {
    
    var objects:[PFObject] = [PFObject]()
    var objectsPerPage = 20
    var currentPage = 0
    var loading:Bool = false
    var lastLoadCount = -1
    var activityIndicator:ActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadObjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        let reload_distance:CGFloat = 15
        if (y > h + reload_distance) && canLoadNextPage() {
            loadNextPage()
        }
    }
    
    func canLoadNextPage() -> Bool {
        return (lastLoadCount == -1 || lastLoadCount >= objectsPerPage) && objects.count != 0
    }
    
    func isLastObjectForIndexPath(indexPath:NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        return (objects.count-1) == indexPath.row
    }
    
    func loadObjects() {
        loadObjects(0, clear: true)
    }
    
    func loadObjects(page:Int, clear:Bool) {
        let storyQuery = queryForTable()
        storyQuery.limit = objectsPerPage
        storyQuery.skip = objectsPerPage*page
        objectsWillLoad()
        loading = true
        storyQuery.findObjectsInBackgroundWithBlock({
            (resultObjects:[PFObject]?, error:NSError?) in
            
            self.loading = false
            
            if error != nil {
                self.lastLoadCount = -1
            } else if let resultObjects = resultObjects {
                self.currentPage = page
                if clear {
                    self.objects.removeAll()
                }
                self.lastLoadCount = resultObjects.count
                self.objects += resultObjects
            }
            self.tableView.reloadData()
            self.objectsDidLoad(error)
        })
    }
    
    func loadNextPage() {
        if !loading {
            loadObjects(currentPage+1, clear: false)
        }
    }
    
    func objectsWillLoad() {
        if activityIndicator == nil {
            var frame = tableView.bounds
            frame.size.height = frame.size.height/2
            activityIndicator = ActivityIndicatorView(frame: frame)
            tableView.addSubview(activityIndicator!)
        }
        if !activityIndicator!.isAnimating() {
            activityIndicator?.startAnimating()
        }
    }
    
    func objectsDidLoad(error: NSError?) {
        activityIndicator?.stopAnimating()
    }
    
    func queryForTable() -> PFQuery {
        return PFQuery()
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath?) -> PFObject? {
        var obj:PFObject? = nil;
        if let indexPath = indexPath where indexPath.row < self.objects.count {
            obj = self.objects[indexPath.row]
        }
        return obj;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

}
