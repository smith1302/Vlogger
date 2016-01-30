//
//  CustomPFQueryTableViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/27/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class CustomPFQueryTableViewController: PFQueryTableViewController {
    
    var activityIndicator:ActivityIndicatorView?
    var showLoader = true {
        willSet {
            if newValue == false {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadingViewEnabled = false
    }
    
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        self.loadingViewEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func objectsWillLoad() {
        super.objectsWillLoad()
        if activityIndicator == nil && showLoader {
            var frame = tableView.bounds
            frame.size.height = frame.size.height/2
            activityIndicator = ActivityIndicatorView(frame: frame)
            tableView.addSubview(activityIndicator!)
        }
        activityIndicator?.startAnimating()
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        activityIndicator?.stopAnimating()
    }

}
