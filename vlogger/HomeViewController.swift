//
//  HomeViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

protocol TransitionToFeedDelegate:class {
    func transitionToFeed(user:User)
    func transitionToFeedWithStory(story:Story, user: User)
}

class HomeViewController: UIViewController, UISearchBarDelegate, SelectorViewControllerDelegate, TransitionToFeedDelegate {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectorContainer: UIView!
    @IBOutlet weak var RightButton: UIButton!
    @IBOutlet weak var LeftButton: UIButton!
    @IBOutlet weak var selectorCenterXConstraint: NSLayoutConstraint!
    var selectorViewController:SelectorViewController!
    var currentChildViewController:UIViewController?
    let kTitle:String = "Explore"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        // Status bar color
        view.backgroundColor = Constants.primaryColor
        backgroundView.backgroundColor = Constants.primaryColorSoft
        self.automaticallyAdjustsScrollViewInsets = false;
        super.viewDidLoad()
        title = kTitle
        
        // Selector View
        selectorViewController = SelectorViewController(RightButton: RightButton, LeftButton: LeftButton, selectorCenterXConstraint: selectorCenterXConstraint, container: selectorContainer)
        addChildViewController(selectorViewController)
        selectorViewController.delegate = self
        
        // Search Bar
        searchBar.delegate = self
        searchBar.searchBarStyle = .Default
        searchBar.backgroundImage = Constants.primaryColor.toImage(searchBar.frame.size)
        searchBar.backgroundColor = Constants.primaryColor
        searchBar.barTintColor = Constants.primaryColor
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = Constants.primaryColor.CGColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Selector Left Set
        selectorViewController.leftButtonClicked()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    /* Selector View Controller Delegate
    ------------------------------------------------------*/
    
    func leftButtonClicked() {
        if selectorViewController.currentState == HomeSelectorState.Search {
            searchUsersButtonClicked()
        } else {
            trendingButtonClicked()
        }
    }
    
    func rightButtonClicked() {
        if selectorViewController.currentState == HomeSelectorState.Search {
            searchStoriesButtonClicked()
        } else {
            subscriptionsButtonClicked()
        }
    }
    
    /* Selector Buttons
    ------------------------------------------------------*/
    
    func clearCurrentChildViewController() {
        currentChildViewController?.view.removeFromSuperview()
        currentChildViewController?.removeFromParentViewController()
        currentChildViewController = nil
    }
    
    var vcCache:[String:UIViewController] = [String:UIViewController]()
    
    func trendingButtonClicked() {
        clearCurrentChildViewController()
        let className = String(TrendingViewController)
        let vc:UIViewController? = (vcCache[className] != nil) ? vcCache[className] : self.storyboard?.instantiateViewControllerWithIdentifier(className)
        if let vc = vc as? TrendingViewController {
            vc.delegate = self
            currentChildViewController = vc
            vcCache[className] = vc
            addContainerViewController(vc, topAlignmentView: selectorContainer)
        }
    }

    func subscriptionsButtonClicked() {
        clearCurrentChildViewController()
        let className = String(StoryUpdateFeedViewController)
        let vc:UIViewController? = (vcCache[className] != nil) ? vcCache[className] : self.storyboard?.instantiateViewControllerWithIdentifier(className)
        if let vc = vc as? StoryUpdateFeedViewController {
            vc.delegate = self
            currentChildViewController = vc
            vcCache[String(StoryUpdateFeedViewController)] = vc
            addContainerViewController(vc, topAlignmentView: selectorContainer)
            vc.configureWithFeedType(StoryUpdateFeedType.subscriptions)
        }
    }

    func searchUsersButtonClicked() {
        clearCurrentChildViewController()
        let className = String(SearchUsersViewController)
        let vc:UIViewController? = (vcCache[className] != nil) ? vcCache[className] : self.storyboard?.instantiateViewControllerWithIdentifier(className)
        if let vc = vc as? SearchUsersViewController {
            vc.delegate = self
            currentChildViewController = vc
            vcCache[className] = vc
            addContainerViewController(vc, topAlignmentView: selectorContainer)
        }
    }

    func searchStoriesButtonClicked() {
        clearCurrentChildViewController()
        let className = String(SearchStoriesViewController)
        let vc:UIViewController? = (vcCache[className] != nil) ? vcCache[className] : self.storyboard?.instantiateViewControllerWithIdentifier(className)
        if let vc = vc as? SearchStoriesViewController {
            vc.delegate = self
            currentChildViewController = vc
            vcCache[className] = vc
            addContainerViewController(vc, topAlignmentView: selectorContainer)
        }
    }
    
    /* Helpers
    ------------------------------------------------------*/
    
    func addContainerViewController(vc:UIViewController, topAlignmentView:UIView) {
        //addChildViewController(vc)
        vc.view.frame = self.view.bounds
        view.addSubview(vc.view)
        
        let subview = vc.view
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Top, relatedBy: .Equal, toItem: topAlignmentView, attribute: .Bottom, multiplier: 1.0, constant: 3))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }
    
    /* Search Bar Delegate
    ------------------------------------------------------*/
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if let _ = currentChildViewController as? SearchViewController { return }

        searchBar.setShowsCancelButton(true, animated: true)
        selectorViewController.currentState = HomeSelectorState.Search
        title = "Search"
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
        if let vc = currentChildViewController as? SearchViewController {
            vc.doSearch(searchBar.text)
            searchBar.resignFirstResponder()
            enableCancelButton()
        }
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        title = kTitle
        selectorViewController.currentState = HomeSelectorState.Home
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
    
    /* Transition to feed delegate
    ------------------------------------------------------*/
    
    func transitionToFeed(user: User) {
        let storyboard = self.storyboard
        if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("FeedViewController") as? FeedViewController {
            self.navigationController?.pushViewController(destinationVC, animated: true)
            destinationVC.configureWithUser(user)
        }
    }
    
    func transitionToFeedWithStory(story: Story, user: User) {
        let storyboard = self.storyboard
        if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("FeedViewController") as? FeedViewController {
            self.navigationController?.pushViewController(destinationVC, animated: true)
            destinationVC.configureWithStory(story, user: user)
        }
    }
    
    /* Go back
    ------------------------------------------------------*/

    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
