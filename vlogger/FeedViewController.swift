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

class FeedViewController: UIViewController, ChatFeedViewControllerDelegate, UIViewControllerTransitioningDelegate {
    
    // Feed Navigation
    var next:FeedViewController?
    var previous:FeedViewController?

    // IBOutlets
    @IBOutlet weak var titleLabel: UITextField?
    @IBOutlet weak var chatDragTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatDragView: UIView!
    @IBOutlet weak var chatDragIndicator: UIView!
    
    // Variables
    var activityIndicator:ActivityIndicatorView!
    var videoFeedController:VideoFeedViewController?
    var chatFeedController:ChatFeedViewController?
    var user:User!
    var story:Story!
    var isStoryOld:Bool = false
    var configured:Bool = false
    var feedLayoutInfo:FeedLayoutInfo!
    
//    func configureWithUser(user:User) {
//        self.user = user
//        self.story = user.currentStory
//        self.story?.user = user
//        configured = true
//        setUpIfPossible()
//    }
    
    func configureWithStory(story:Story?) {
        if story == nil {
            self.noVideosFound()
            return
        }
        self.user = story!.user
        self.story = story!
        configured = true
        setUpIfPossible()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start it off hidden
        chatDragTopConstraint.constant = view.frame.size.height
        view.userInteractionEnabled = true
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillHideNotification, object: nil)
        
        // Feed Layout
        feedLayoutInfo = FeedLayoutInfo(chatTopConstraint: chatDragTopConstraint, originalViewHeight: view.frame.size.height, chatDragViewHeight: chatDragView.frame.size.height, toolbarHeight: 50)
        
        // Title Label
        titleLabel?.textColor = UIColor(white: 0.4, alpha: 1)
        titleLabel?.userInteractionEnabled = false
        titleLabel?.text = "Chat"
        
        // Activity Indicator View
        activityIndicator = ActivityIndicatorView(frame: view.bounds)
        view.addSubview(activityIndicator)
        Utilities.autolayoutSubviewToViewEdges(activityIndicator, view: view)
        
        // Dragger
        chatDragView.backgroundColor = UIColor(white: 1, alpha: 1)
        chatDragView.layer.borderColor = UIColor(white: 0.85, alpha: 1).CGColor
        chatDragView.layer.borderWidth = 1
        
        // Move dragger to the bottom to show video full screen
        closeChat()
        
        setUpIfPossible()
    }
    
    func setUpIfPossible() {
        if videoFeedController == nil || user == nil || chatFeedController == nil {
            return
        }
        viewIsConfigured()
    }
    
    func viewIsConfigured() {
        story.fetchIfNeededInBackgroundWithBlock({
            (object:PFObject?, error:NSError?) in
            if let story = object as? Story {
                story.cache()
                self.videoFeedController?.configureStory(story)
                self.chatFeedController?.configure(story)
                self.user.fetchIfNeededInBackgroundWithBlock({
                    (object:PFObject?, error:NSError?) in
                    if let user = object as? User {
                        self.isStoryOld = story.objectId != user.currentStory!.objectId
                    }
                })
            } else {
                self.noVideosFound()
            }
        })
        videoFeedController?.configureWithUser(user)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveLinear, animations: {
            self.chatDragIndicator.alpha = 1
            self.chatDragView.alpha = 1
        }, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarHidden = true
        super.viewWillAppear(animated)
        // Autolayout doesnt configure the constraints until AFTER the view appears. So hide them now and unhide them in viewdidappear...
        self.chatDragIndicator.alpha = 0
        self.chatDragView.alpha = 0
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        activityIndicator.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func noVideosFound() {
        self.videoFeedController?.noVideosFound()
        self.feedLayoutInfo.bottomDragLimit = self.feedLayoutInfo.originalViewHeight
        closeChat()
    }

    @IBAction func chatDrag(sender: UIPanGestureRecognizer) {
        let velocityY = sender.velocityInView(self.view).y
        let translation = sender.translationInView(self.view)
        let newY = chatDragView.frame.origin.y + translation.y
        
        if newY < 0 {
            return
        }
        
        // If the keyboard is showing for the chat message and we are dragging below the limits, hide the keyboard
        if let titleLabel = titleLabel where !titleLabel.isFirstResponder() && feedLayoutInfo.keyboardShowing && newY >= feedLayoutInfo.bottomDragLimit + feedLayoutInfo.toolbarHeight*0.75 {
            chatFeedController?.textField.resignFirstResponder()
        }
        
        let dragEnded = sender.state == .Ended || sender.state == .Cancelled || sender.state == .Failed
        let throwThreshold:CGFloat = 500
        if dragEnded && velocityY < -throwThreshold {
            openChat()
        } else if dragEnded && velocityY > throwThreshold {
            closeChat()
        } else if dragEnded {
            chatDragRelease(chatDragView)
        } else {
            chatDragTopConstraint.constant = newY
            sender.setTranslation(CGPointZero, inView: self.view)
            view.layoutIfNeeded()
        }
    }

    func chatDragRelease(sender: UIView) {
        let y = sender.center.y
        if y < feedLayoutInfo.topDragLimit + view.frame.size.height * FeedLayoutInfo.snapThreshold {
            animateChatDraggerToConstraintConstant(0)
        } else if y >= feedLayoutInfo.bottomDragLimit - view.frame.size.height * FeedLayoutInfo.snapThreshold {
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
        chatDragTopConstraint.constant = feedLayoutInfo.topDragLimit
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func closeChat() {
        chatDragTopConstraint.constant = feedLayoutInfo.bottomDragLimit
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        let distance = (feedLayoutInfo.bottomDragLimit - feedLayoutInfo.bottomDragLimit*2/3)
//        let positionOffset = chatDragTopConstraint.constant - feedLayoutInfo.bottomDragLimit*2/3
//        let percent = positionOffset/distance
//        chatDragIndicator.alpha = max(0,percent)
//    }
    
    /* ChatFeedViewControllerDelegate
    ------------------------------------------------------*/
    
    func toolBarHeightUpdated(height: CGFloat) {
        feedLayoutInfo.toolbarHeight = height
    }
    
    func willSegueToDifferentUserFeed() {
        activityIndicator.startAnimating()
    }
    
    func segueToDifferentUserFeedFailed() {
        activityIndicator.stopAnimating()
    }
    
    /* Keyboard Notifications
    -------------------------------------------*/
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if notification.name == UIKeyboardWillShowNotification {
                feedLayoutInfo.keyboardWillShow()
            } else if notification.name == UIKeyboardWillHideNotification {
                feedLayoutInfo.keyboardWillHide()
            }
            
            if let titleLabel = titleLabel where titleLabel.isFirstResponder() {
                feedLayoutInfo.setUpKeyboardLayoutForTitleLabel(notification, endFrame: endFrame)
            } else {
                feedLayoutInfo.setUpKeyboardLayoutForChatMessage(notification, endFrame: endFrame)
            }
            
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: {
                    self.view.frame.size.height = self.feedLayoutInfo.frameHeight
                    self.view.layoutIfNeeded()
                },
                completion: nil)
        }
    }
    
    /* Title Text Field
    ------------------------------------------------------*/
    
//    func textFieldDidBeginEditing(textField: UITextField) {
//        animateChatDraggerToConstraintConstant(feedLayoutInfo.bottomDragLimit-chatDragView.frame.size.height)
//        chatDragIndicator.hidden = true
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return false
//    }
//    
//    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
//        if !isStoryOld {
//            chatDragIndicator.hidden = false
//        }
//        if let story = story, newText = textField.text where newText != story.title && !newText.isEmpty {
//            story.title = newText
//            story.tags = story.getTagsFromString(newText)
//            story.saveEventually()
//        }
//        return true
//    }
//    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        let oldString = textField.text ?? ""
//        let startIndex = oldString.startIndex.advancedBy(range.location)
//        let endIndex = startIndex.advancedBy(range.length)
//        let newString = oldString.stringByReplacingCharactersInRange(startIndex ..< endIndex, withString: string)
//        return newString.characters.count <= 40
//    }
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        // If we are editing the titleLabel, hide keyboard if we touch anything but the chatDragView
//        if let touchedView = touches.first?.view, titleLabel = titleLabel where titleLabel.isFirstResponder() && touchedView != chatDragView {
//            titleLabel.resignFirstResponder()
//        }
//    }
    
    
    /* Helpers
    ------------------------------------------------------*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? VideoFeedViewController {
            videoFeedController = vc
        }
        
        if let vc = segue.destinationViewController as? ChatFeedViewController {
            chatFeedController = vc
            vc.delegate = self
        }
    }
    
    func pause() {
        videoFeedController?.pause()
    }
    
    func play() {
        videoFeedController?.play()
    }
    
}

// Deals with all the keyboard layout changes
class FeedLayoutInfo {
    
    var keyboardShowing:Bool
    var originalViewHeight:CGFloat
    var topDragLimit:CGFloat
    var bottomDragLimit:CGFloat    // Lowest possible drag point
    var chatDragViewHeight:CGFloat
    var toolbarHeight:CGFloat
    static let snapThreshold:CGFloat = 0.23
    var chatTopBeforeKeyboard:CGFloat
    var bottomDragBuffer:CGFloat
    
    // Use these to get final changes after setting up
    var chatDragTopConstraint:NSLayoutConstraint
    var frameHeight:CGFloat
    
    init(chatTopConstraint:NSLayoutConstraint, originalViewHeight:CGFloat, chatDragViewHeight:CGFloat, toolbarHeight:CGFloat) {
        self.keyboardShowing = false
        self.originalViewHeight = originalViewHeight
        self.topDragLimit = 0
        self.bottomDragBuffer = 0//chatDragViewHeight
        self.bottomDragLimit = originalViewHeight-bottomDragBuffer
        self.chatDragViewHeight = chatDragViewHeight
        self.toolbarHeight = toolbarHeight
        self.chatDragTopConstraint = chatTopConstraint
        self.chatTopBeforeKeyboard = chatDragTopConstraint.constant
        self.frameHeight = originalViewHeight
    }
    
    func setUpKeyboardLayoutForTitleLabel(notification:NSNotification, endFrame:CGRect?) {
        if let endFrameHeight = endFrame?.size.height where notification.name == UIKeyboardWillShowNotification {
            frameHeight = originalViewHeight-endFrameHeight
            bottomDragLimit = frameHeight-bottomDragBuffer
            chatDragTopConstraint.constant = bottomDragLimit
        } else {
            chatDragTopConstraint.constant = chatTopBeforeKeyboard
            frameHeight = originalViewHeight
        }
        chatDragTopConstraint.constant = CGFloat(max(0, Double(chatDragTopConstraint.constant)))
    }
    
    func setUpKeyboardLayoutForChatMessage(notification:NSNotification, endFrame:CGRect?) {
        if let endFrameHeight = endFrame?.size.height where notification.name == UIKeyboardWillShowNotification {
            chatDragTopConstraint.constant = chatTopBeforeKeyboard - endFrameHeight
            frameHeight = originalViewHeight-endFrameHeight
            bottomDragLimit = originalViewHeight-chatDragViewHeight-toolbarHeight-endFrameHeight
        } else {
            chatDragTopConstraint.constant = chatTopBeforeKeyboard
            frameHeight = originalViewHeight
        }
        chatDragTopConstraint.constant = CGFloat(max(0, Double(chatDragTopConstraint.constant)))
    }
    
    func keyboardWillShow() {
        if keyboardShowing == true {
            return
        }
        keyboardShowing = true
        chatTopBeforeKeyboard = chatDragTopConstraint.constant
    }
    
    func keyboardWillHide() {
        if keyboardShowing == false {
            return
        }
        bottomDragLimit = originalViewHeight-bottomDragBuffer
        keyboardShowing = false
    }
}
