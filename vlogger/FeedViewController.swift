//
//  FeedViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/5/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Parse

class FeedViewController: UIViewController, ProfileCardViewControllerDelegate, ChatFeedViewControllerDelegate {
    
    @IBOutlet weak var chatDragTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatDragView: UIView!
    @IBOutlet weak var chatDragIndicator: UIView!
    
    var profileCardViewController:ProfileCardViewController?
    var activityIndicator:ActivityIndicatorView!
    private var user:User!
    private var story:Story?
    
    var topDragLimit:CGFloat!
    var bottomDragLimit:CGFloat!    // Lowest possible drag point
    let snapThreshold:CGFloat = 0.25
    var draggingEnabled:Bool {
        get {
            return story == nil
        }
    }
    
    func configureWithUser(user:User) {
        self.user = user
    }
    
    func configureWithStory(story:Story) {
        self.user = story.user
        self.story = story
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start it off hidden
        chatDragTopConstraint.constant = view.frame.size.height
        view.userInteractionEnabled = true
        topDragLimit = 0
        bottomDragLimit = view.frame.size.height
        chatDragIndicator.alpha = (draggingEnabled) ? 1 : 0
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillHideNotification, object: nil)
        
        // Activity Indicator View
        activityIndicator = ActivityIndicatorView(frame: view.bounds)
        view.addSubview(activityIndicator)
        Utilities.autolayoutSubviewToViewEdges(activityIndicator, view: view)
        
        // Move dragger to the bottom to show video full screen
        closeChat()

    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        activityIndicator.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func chatDrag(sender: UIPanGestureRecognizer) {
        // No chat enabled for viewing past stories
        if !draggingEnabled { return }
        
        let translation = sender.translationInView(self.view)
        let newY = chatDragView.frame.origin.y + translation.y
        
        // Don't hide textbox when keyboard is open
        if newY >= bottomDragLimit || newY < 0 {
            return
        }
        
        chatDragTopConstraint.constant = newY
        sender.setTranslation(CGPointZero, inView: self.view)
        view.layoutIfNeeded()
        
        if sender.state == .Ended || sender.state == .Cancelled || sender.state == .Failed {
            chatDragRelease(chatDragView)
        }
    }

    func chatDragRelease(sender: UIView) {
        let y = sender.center.y
        if y < topDragLimit + view.frame.size.height * snapThreshold {
            animateChatDraggerToConstraintConstant(0)
        } else if y >= bottomDragLimit - view.frame.size.height * snapThreshold {
            closeChat()
        }
    }
    
    func animateChatDraggerToConstraintConstant(constant:CGFloat) {
        chatDragTopConstraint.constant = constant
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func openChat() {
        chatDragTopConstraint.constant = topDragLimit
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func closeChat() {
        chatDragTopConstraint.constant = bottomDragLimit
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLayoutSubviews() {
        if !draggingEnabled { return }
        let distance = (bottomDragLimit - bottomDragLimit*2/3)
        let positionOffset = chatDragTopConstraint.constant - bottomDragLimit*2/3
        let percent = positionOffset/distance
        chatDragIndicator.alpha = max(0,percent)
    }
    
    
    /* ProfileCardViewControllerDelegate
    ------------------------------------------------------*/
    
    func profileCardClosed() {
        profileCardViewController = nil
    }
    
    /* ChatFeedViewControllerDelegate
    ------------------------------------------------------*/
    
    var toolbarHeight:CGFloat = 50
    func toolBarHeightUpdated(height: CGFloat) {
        self.toolbarHeight = height
    }
    
    func willSegueToDifferentUserFeed() {
        activityIndicator.startAnimating()
    }
    
    func segueToDifferentUserFeedFailed() {
        activityIndicator.stopAnimating()
    }
    
    /* Keyboard Notifications
    -------------------------------------------*/
    
    var keyboardShowing:Bool = false
    var chatTopConstraintBeforeKeyboard:CGFloat!
    var originalViewHeight:CGFloat!
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if keyboardShowing == false && notification.name == UIKeyboardWillShowNotification {
                keyboardShowing = true
                chatTopConstraintBeforeKeyboard = self.chatDragTopConstraint.constant
                originalViewHeight = view.frame.size.height
            } else if keyboardShowing == true && notification.name == UIKeyboardWillHideNotification {
                bottomDragLimit = originalViewHeight-chatDragView.frame.size.height
                keyboardShowing = false
            }
            
            var newTopConstant:CGFloat = bottomDragLimit
            var frameHeightConstant:CGFloat = view.frame.size.height
            if let endFrameHeight = endFrame?.size.height where notification.name == UIKeyboardWillShowNotification {
                newTopConstant = chatTopConstraintBeforeKeyboard - endFrameHeight
                frameHeightConstant = originalViewHeight-endFrameHeight
                bottomDragLimit = originalViewHeight-chatDragView.frame.size.height-toolbarHeight-endFrameHeight
            } else {
                newTopConstant = chatTopConstraintBeforeKeyboard
                frameHeightConstant = originalViewHeight
            }
            newTopConstant = CGFloat(max(0, Double(newTopConstant)))
            chatDragTopConstraint.constant = newTopConstant
            
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: {
                    self.view.frame.size.height = frameHeightConstant
                    self.view.layoutIfNeeded()
                },
                completion: nil)
        }
    }
    
    /* Helpers
    ------------------------------------------------------*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? VideoFeedViewController {
            if let story = story {
                vc.configureStory(story)
            } else {
                vc.configureWithUser(user)
            }
        }
        
        if let vc = segue.destinationViewController as? ChatFeedViewController {
            vc.delegate = self
            vc.configure(user)
        }
    }
    
}
