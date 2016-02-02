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
    @IBOutlet weak var selector: UIView!
    
    var selectorViewController:SelectorViewController!
    var currentChildViewController:UIViewController?
    let kTitle:String = "Explore"
    let childViewControllerSlideDuration:NSTimeInterval = 0.3
    
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
        selectorViewController = SelectorViewController(RightButton: RightButton, LeftButton: LeftButton, selectorCenterXConstraint: selectorCenterXConstraint, container: selectorContainer, selector: selector)
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
        hideSearchBar(false)
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
    
    func clearCurrentChildViewController(direction:SlideDirection) {
        if currentChildViewController == nil {
            return
        }
        let vc = currentChildViewController!
        currentChildViewController = nil
        UIView.animateWithDuration(childViewControllerSlideDuration, animations: {
                let width = vc.view.frame.width
                let endX = direction == .Left ? -width : width
                vc.view.transform = CGAffineTransformMakeTranslation(endX, 0)
            }, completion: {
                finished in
                vc.view.removeFromSuperview()
                vc.removeFromParentViewController()
        })
    }
    
    var vcCache:[String:UIViewController] = [String:UIViewController]()
    
    func trendingButtonClicked() {
        let className = String(TrendingViewController)
        let vc:UIViewController? = (vcCache[className] != nil) ? vcCache[className] : self.storyboard?.instantiateViewControllerWithIdentifier(className)
        if let vc = vc as? TrendingViewController {
            vc.delegate = self
            vcCache[className] = vc
            addContainerViewController(vc, topAlignmentView: selectorContainer, direction: .Left)
        }
    }

    func subscriptionsButtonClicked() {
        let className = String(StoryUpdateFeedViewController)
        let vc:UIViewController? = (vcCache[className] != nil) ? vcCache[className] : self.storyboard?.instantiateViewControllerWithIdentifier(className)
        if let vc = vc as? StoryUpdateFeedViewController {
            vc.delegate = self
            vcCache[String(StoryUpdateFeedViewController)] = vc
            addContainerViewController(vc, topAlignmentView: selectorContainer, direction: .Right)
        }
    }

    func searchUsersButtonClicked() {
        let className = String(SearchUsersViewController)
        let vc:UIViewController? = (vcCache[className] != nil) ? vcCache[className] : self.storyboard?.instantiateViewControllerWithIdentifier(className)
        if let vc = vc as? SearchUsersViewController {
            vc.delegate = self
            vcCache[className] = vc
            addContainerViewController(vc, topAlignmentView: selectorContainer, direction: .Left)
        }
    }

    func searchStoriesButtonClicked() {
        let className = String(SearchStoriesViewController)
        let vc:UIViewController? = (vcCache[className] != nil) ? vcCache[className] : self.storyboard?.instantiateViewControllerWithIdentifier(className)
        if let vc = vc as? SearchStoriesViewController {
            vc.delegate = self
            vcCache[className] = vc
            addContainerViewController(vc, topAlignmentView: selectorContainer, direction: .Right)
        }
    }
    
    /* Helpers
    ------------------------------------------------------*/
    
    enum SlideDirection:Int {
        case Right
        case Left
    }
    
    func addContainerViewController(vc:UIViewController, topAlignmentView:UIView, direction:SlideDirection) {
        clearCurrentChildViewController(direction)
        currentChildViewController = vc
        vc.view.frame = self.view.bounds
        view.addSubview(vc.view)
        
        let subview = vc.view
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Top, relatedBy: .Equal, toItem: topAlignmentView, attribute: .Bottom, multiplier: 1.0, constant: 3))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        
        let width = self.currentChildViewController!.view.frame.width
        let startX = direction == .Left ? width : -width
        self.currentChildViewController!.view.transform = CGAffineTransformMakeTranslation(startX, 0)
        UIView.animateWithDuration(childViewControllerSlideDuration, animations: {
            self.currentChildViewController!.view.transform = CGAffineTransformMakeTranslation(0, 0)
            }, completion: {
                finished in
        })
    }
    
    /* Search Bar Delegate
    ------------------------------------------------------*/
    
    
    @IBAction func searchButtonClicked(sender: AnyObject) {
        searchBar.becomeFirstResponder()
        showSearchBar(true)
    }

    
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
        hideSearchBar(true)
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
    
    func hideSearchBar(animated:Bool) {
        let time = animated ? 0.2 : 0
        UIView.animateWithDuration(time, animations: {
            self.searchBar.transform = CGAffineTransformMakeTranslation(-self.searchBar.frame.size.width, 0)
        })
    }
    
    func showSearchBar(animated:Bool) {
        view.bringSubviewToFront(searchBar)
        let time = animated ? 0.2 : 0
        UIView.animateWithDuration(time, animations: {
            self.searchBar.transform = CGAffineTransformMakeTranslation(0, 0)
        })
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
