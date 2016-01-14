//
//  HomeViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var selectorContainer: UIView!
    @IBOutlet weak var trendingButton: UIButton!
    @IBOutlet weak var subscriptionsButton: UIButton!
    @IBOutlet weak var selectorCenterXConstraint: NSLayoutConstraint!
    var selectorViewController:SelectorViewController!
    
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false;
        super.viewDidLoad()
        
        // Selector View
        selectorViewController = SelectorViewController(trendingButton: trendingButton, subscriptionsButton: subscriptionsButton, selectorCenterXConstraint: selectorCenterXConstraint, container: selectorContainer)
        addChildViewController(selectorViewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.navigationBarHidden = false
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return self
    }
    
    

}
