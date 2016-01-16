//
//  HomeViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UISearchBarDelegate, SelectorViewControllerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectorContainer: UIView!
    @IBOutlet weak var trendingButton: UIButton!
    @IBOutlet weak var subscriptionsButton: UIButton!
    @IBOutlet weak var selectorCenterXConstraint: NSLayoutConstraint!
    var selectorViewController:SelectorViewController!
    var currentChildViewController:UIViewController?
    let kTitle:String = "Explore"
    
    
    override func viewDidLoad() {
        // Fixes childViewController having space for navbar
        self.automaticallyAdjustsScrollViewInsets = false;
        super.viewDidLoad()
        title = kTitle
        
        // Selector View
        selectorViewController = SelectorViewController(trendingButton: trendingButton, subscriptionsButton: subscriptionsButton, selectorCenterXConstraint: selectorCenterXConstraint, container: selectorContainer)
        addChildViewController(selectorViewController)
        selectorViewController.delegate = self
        
        // Search Bar
        searchBar.delegate = self
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
    
    /* Selector View Controller Delegate
    ------------------------------------------------------*/
    
    func subscriptionClicked() {
        currentChildViewController?.view.removeFromSuperview()
        currentChildViewController?.removeFromParentViewController()
        currentChildViewController = nil
    }
    
    func trendingClicked() {
        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TrendingViewController") as? TrendingViewController {
            currentChildViewController = vc
            addContainerViewController(vc, topAlignmentView: selectorContainer)
        }
    }
    
    /* Helpers
    ------------------------------------------------------*/
    
    func addContainerViewController(vc:UIViewController, topAlignmentView:UIView) {
        addChildViewController(vc)
        vc.view.frame = self.view.bounds
        view.addSubview(vc.view)
        
        let subview = vc.view
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Top, relatedBy: .Equal, toItem: topAlignmentView, attribute: .Bottom, multiplier: 1.0, constant: 2))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }
    
    /* Search Bar Delegate
    ------------------------------------------------------*/
    
    var searchViewController:SearchViewController?
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if searchViewController != nil { return }

        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SearchViewController") as? SearchViewController {
            searchViewController = vc
            addContainerViewController(vc, topAlignmentView: searchBar)
            searchBar.setShowsCancelButton(true, animated: true)
            title = "Search"
        }
    
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {}

    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
            let oldString = textField.text ?? ""
            let startIndex = oldString.startIndex.advancedBy(range.location)
            let endIndex = startIndex.advancedBy(range.length)
            let newString = oldString.stringByReplacingCharactersInRange(startIndex ..< endIndex, withString: string)
            return newString.characters.count <= 40
        }
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchViewController?.doSearch(searchBar.text)
        searchBar.resignFirstResponder()
        enableCancelButton() 
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchViewController?.view.removeFromSuperview()
        searchViewController?.removeFromParentViewController()
        searchViewController = nil
        title = kTitle
    }
    
    func enableCancelButton() {
        for view in searchBar.subviews {
            for subview in view.subviews {
                if let button = subview as? UIButton {
                    button.enabled = true
                }
            }
        }
    }

}
