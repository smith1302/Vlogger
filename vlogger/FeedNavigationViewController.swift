//
//  FeedNavigationViewController.swift
//  vlogger
//
//  Created by Eric Smith on 2/3/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import Parse

enum FeedShiftDirection:Int {
    case Left
    case Right
}

class FeedNavigationViewController: UIViewController, FeedViewControllerAnimationDelegate {
    
    var sessionQueue = dispatch_queue_create("feedNavigationQueue", DISPATCH_QUEUE_SERIAL)
    var currentFeedViewController:FeedViewController!
    //var feedViewControllers:[Story:FeedViewController] = [Story:FeedViewController]()
    var stories:[Story] = [Story]()
    var query:PFQuery!
    var currentStoryIndex:Int = 0 // Use increaseCurrentStoryIndex()
    var currentPage:Int = 0
    var objectsPerPage:Int = 10
    var loadingStories:Bool = false
    var numObjectsLastLoaded:Int = 0
    var feedControllerAnimator:FeedViewControllerAnimation?

    init(initialStory:Story?, query:PFQuery?) {
        super.init(nibName: nil, bundle: nil)
        
        let endQuery:PFQuery = (query == nil) ? Queries.trendingStoriesQuery(exclude: initialStory) : query!
        self.query = endQuery
        
        if let story = initialStory {
            stories.append(story)
        }
        currentFeedViewController = instantiateFeedVC(initialStory)
        loadObjects(currentPage, clear: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addFeedToView(currentFeedViewController)
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "didPanGesture:"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadObjects(page:Int, clear:Bool) {
        if loadingStories {
            return
        }
        loadingStories = true
        let skip = page*objectsPerPage
        query.skip = skip
        query.limit = objectsPerPage
        query.findObjectsInBackgroundWithBlock({
            (objects:[PFObject]?, error:NSError?) in
            if clear {
                self.stories.removeAll()
            }
            if let objects = objects as? [Story] {
                for object in objects {
                    object.preBuffer()
                }
                self.stories += objects
                self.numObjectsLastLoaded = objects.count
                print("More stories added")
            } else {
                self.numObjectsLastLoaded = -1
            }
            self.currentPage = page
            self.loadingStories = false
            self.storiesDidLoad(error)
        })
    }
    
    func storiesDidLoad(error:NSError?) {
        if let story = self.getCurrentStory() where currentFeedViewController.configured == false {
            currentFeedViewController.configureWithStory(story)
        } else if currentFeedViewController.configured == false && loadingStories == false {
            // Go back a controller
        }
    }
    
    func addFeedToView(feedVC:FeedViewController?) {
        if let feedVC = feedVC {
            addChildViewController(feedVC)
            feedVC.view.frame = view.bounds
            view.addSubview(feedVC.view)
        }
    }
    
    func removeFeedFromView(feedVC:FeedViewController) {
        feedVC.view.removeFromSuperview()
        feedVC.removeFromParentViewController()
    }
    
    func instantiateFeedVC() -> FeedViewController! {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle());
        let vc = storyboard.instantiateViewControllerWithIdentifier("FeedViewController") as! FeedViewController
        return vc
    }
    
    func instantiateFeedVC(story:Story?) -> FeedViewController! {
        let vc = instantiateFeedVC()
        vc.configureWithStory(story)
        return vc
    }
    
    func getCurrentStory() -> Story? {
        if currentStoryIndex < stories.count {
            return stories[currentStoryIndex]
        }
        return nil
    }
    
    func canShowPrevious() -> Bool {
        return currentStoryIndex > 0
    }
    
    func canShowNext() -> Bool {
        // If we have more stories to show then sure
        return currentStoryIndex < stories.count-1
    }
    
    func getNextFeedVC() -> FeedViewController? {
        if !canShowNext() {
            return nil
        }
        let nextStoryIndex = currentStoryIndex+1
        let story = stories[nextStoryIndex]
        let vc = instantiateFeedVC()
        vc.configureWithStory(story)
        return vc
    }
    
    func getPrevFeedVC() -> FeedViewController? {
        if !canShowPrevious() {
            return nil
        }
        let prevStoryIndex = currentStoryIndex-1
        let story = stories[prevStoryIndex]
        let vc = instantiateFeedVC()
        vc.configureWithStory(story)
        return vc
    }
    
    func increaseCurrentStoryIndex() {
        let storyCount = stories.count
        if currentStoryIndex < storyCount {
            currentStoryIndex++
        }
    }
    
    func decreaseCurrentStoryIndex() {
        if currentStoryIndex > 0 {
            currentStoryIndex--
        }
    }
    
//    func addFeedWithStoryToList(story:Story, feedVC:FeedViewController) {
//        self.feedViewControllers[story] = feedVC
//    }
    
    /* Pan Gesture
    ---------------------------------*/

    func didPanGesture(pan : UIPanGestureRecognizer) {
        let translation = pan.translationInView(pan.view!)
        let d =  translation.x / pan.view!.bounds.width
        switch pan.state {
        case UIGestureRecognizerState.Began :
            break
        case UIGestureRecognizerState.Changed :
            if feedControllerAnimator == nil {
                if d < 0 {
                    createControllerAnimatorForNext()
                } else if d > 0 {
                    createControllerAnimatorForPrevious()
                }
            } else {
                feedControllerAnimator?.updateMovement(translation)
            }
        default:
            print("Pan Ended")
            feedControllerAnimator?.finishInteraction(pan.velocityInView(pan.view!))
//            let finishGoal:CGFloat = 0.2
//            if (d < finishGoal && d > -finishGoal) {
//            }
            
            
        }
    }
    
    func createControllerAnimatorForNext() {
        createControllerAnimator(.Left)
    }
    
    func createControllerAnimatorForPrevious() {
        createControllerAnimator(.Right)
    }
    
    func createControllerAnimator(direction:SwipeDirection) {
        if feedControllerAnimator != nil {
            return
        }
        let vc:FeedViewController?
        if direction == .Left {
            vc = getNextFeedVC()
            addFeedToView(vc)
            view.bringSubviewToFront(currentFeedViewController.view)
        } else {
            vc = getPrevFeedVC()
            addFeedToView(vc)
        }
        feedControllerAnimator = FeedViewControllerAnimation(currentVC: currentFeedViewController, toVC: vc, direction: direction, width: view.frame.size.width)
        feedControllerAnimator?.delegate = self
    }
    
    /* FeedViewControllerAnimationDelegate
    ----------------------------------------------*/
    
    func animationCancelled(toRemove:FeedViewController?) {
        cleanUpAnimator(toRemove)
    }
    
    func animationFinished(destinationVC:FeedViewController, toRemove:FeedViewController?, swipeDirection:SwipeDirection) {
        cleanUpAnimator(toRemove)
        if swipeDirection == .Left {
            nextSwipeFinished(destinationVC)
        } else {
            backSwipFinished(destinationVC)
        }
        currentFeedViewController = destinationVC
    }
    
    func nextSwipeFinished(destinationVC:FeedViewController) {
        self.increaseCurrentStoryIndex()
        // Could do this before the animation to preload objects
        if let story = self.getCurrentStory() {
//            destinationVC.configureWithStory(story, user: story.user)
//            addFeedWithStoryToList(story, feedVC: destinationVC)
        } else {
            self.loadObjects(self.currentPage+1, clear: false)
        }
    }
    
    func backSwipFinished(destinationVC:FeedViewController) {
        self.decreaseCurrentStoryIndex()
        if let story = self.getCurrentStory() {
//            destinationVC.configureWithStory(story, user: story.user)
//            addFeedWithStoryToList(story, feedVC: destinationVC)
        }
    }
    
    func cleanUpAnimator(toRemove: FeedViewController?) {
        print("Animator Cleaned Up")
        if let remove = toRemove {
            removeFeedFromView(remove)
        }
        feedControllerAnimator = nil
    }

}

protocol FeedViewControllerAnimationDelegate:class {
    func animationFinished(destinationVC:FeedViewController, toRemove:FeedViewController?, swipeDirection:SwipeDirection)
    func animationCancelled(toRemove:FeedViewController?)
}

class FeedViewControllerAnimation:NSObject {

    let currentVC:FeedViewController
    let toVC:FeedViewController?
    let width:CGFloat
    let movementProperties:ControllerAnimationProperties
    let direction:SwipeDirection
    weak var delegate:FeedViewControllerAnimationDelegate?
    var currentTranslation:CGPoint
    let animationDuration:NSTimeInterval
    
    init(currentVC:FeedViewController, toVC:FeedViewController?, direction:SwipeDirection , width:CGFloat) {
        print("Animator Created")
        currentVC.pause()
        toVC?.pause()
        self.currentVC = currentVC
        self.toVC = toVC
        self.direction = direction
        self.width = width
        self.currentTranslation = CGPointMake(0, 0)
        
        if direction == .Left { // Next
            self.movementProperties = ControllerAnimationProperties(controller: currentVC, initial:CGPointMake(0, 0), final:CGPointMake(-width, 0))
        } else if direction == .Right && toVC != nil { // Previous
            self.movementProperties = ControllerAnimationProperties(controller: toVC!, initial:CGPointMake(-width, 0), final:CGPointMake(0, 0))
        } else {
            self.movementProperties = ControllerAnimationProperties(controller: currentVC, initial:CGPointMake(0, 0), final:CGPointMake(width, 0))
        }
        self.movementProperties.updatePercentComplete(0)
        animationDuration = 0.4
        
    }
    
    func updateMovement(translation:CGPoint) {
        var translationX = translation.x
        
        // If there's no VC to go to we just do a fun "snapping" effect by slowing down the rate of drag
        // X => translation
        // Y (output) => percent
        if toVC == nil {
            translationX /= 3
        }
        
        var percent = translationX/movementProperties.translationNeeded()
        if percent < 0 {
            return
        }
        percent = abs(percent)
        movementProperties.updatePercentComplete(percent)
        
    }
    
    func cancelInteraction() {
        let duration = 0.2*Double(1-movementProperties.percentComplete)
        UIView.animateWithDuration(duration, animations: {
            self.movementProperties.updatePercentComplete(0)
            }, completion: {
                finished in
                self.currentVC.play()
                self.resetAllTransforms()
                self.delegate?.animationCancelled(self.toVC)
        })
    }

    func finishInteraction(velocity:CGPoint) {
        if movementProperties.percentComplete < 0.1 {
            cancelInteraction()
            return
        }
        let velocityThreshold:CGFloat = 100
        if (direction == .Left && velocity.x > velocityThreshold) || (direction == .Right && velocity.x < -velocityThreshold){
            cancelInteraction()
            return
        }
        
        if toVC == nil {
            cancelInteraction()
            return
        }
        
        let duration = animationDuration*Double(1-movementProperties.percentComplete)
        UIView.animateWithDuration(duration, animations: {
                self.movementProperties.updatePercentComplete(1)
            }, completion: {
                finished in
                self.toVC!.play()
                self.resetAllTransforms()
                self.delegate?.animationFinished(self.toVC!, toRemove: self.currentVC, swipeDirection: self.direction)
        })
    }


//    /* Helper
//    ----------------------------------------------*/
//    
    func resetAllTransforms() {
        self.currentVC.view.transform = CGAffineTransformIdentity
        self.toVC?.view.transform = CGAffineTransformIdentity
    }
    
}

class ControllerAnimationProperties:NSObject {
    let controller:FeedViewController
    let initial:CGPoint
    let final:CGPoint
    var percentComplete:CGFloat
    
    init(controller:FeedViewController, initial:CGPoint, final:CGPoint) {
        self.controller = controller
        self.initial = initial
        self.final = final
        self.percentComplete = 0
    }
    
    func translationNeeded() -> CGFloat {
        return final.x - initial.x
    }
    
    func updatePercentComplete(percent:CGFloat) {
        percentComplete = percent
        controller.view.transform = CGAffineTransformMakeTranslation(initial.x + percentComplete*translationNeeded(), 0)
    }
}
