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

class FeedViewController: UIViewController, ProfileCardViewControllerDelegate, ChatFeedViewControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var chatDragTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatDragView: UIView!
    @IBOutlet weak var chatDragIndicator: UIView!
    
    var profileCardViewController:ProfileCardViewController?
    var activityIndicator:ActivityIndicatorView!
    var videoFeedController:VideoFeedViewController?
    var chatFeedController:ChatFeedViewController?
    private var user:User!
    private var story:Story? {
        didSet {
            if let story = self.story {
                isStoryOld = story.day < NSDate.getCurrentDay()
            }
        }
    }
    
    var topDragLimit:CGFloat!
    var bottomDragLimit:CGFloat!    // Lowest possible drag point
    let snapThreshold:CGFloat = 0.25
    var isStoryOld:Bool = false
    
    func configureWithUser(user:User) {
        self.user = user
        user.getCurrentStory({
            (story:Story?) in
            if let story = story {
                self.story = story
                self.videoFeedController?.configureStory(story)
            } else {
                self.videoFeedController?.noVideosFound()
            }
        })
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
        chatDragIndicator.alpha = (isStoryOld) ? 0 : 1
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillHideNotification, object: nil)
        
        // Keyboard
        keyboardSetup()
        
        // Title Label
        titleLabel.delegate = self
        
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
        if isStoryOld {
            return
        }
        
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
        if isStoryOld { return }
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
    
    func keyboardSetup() {
        chatTopConstraintBeforeKeyboard = self.chatDragTopConstraint.constant
        originalViewHeight = view.frame.size.height
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if keyboardShowing == false && notification.name == UIKeyboardWillShowNotification {
                keyboardShowing = true
                keyboardSetup()
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
    
    /* Title Text Field
    ------------------------------------------------------*/
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        titleLabel.resignFirstResponder()
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldString = textField.text ?? ""
        let startIndex = oldString.startIndex.advancedBy(range.location)
        let endIndex = startIndex.advancedBy(range.length)
        let newString = oldString.stringByReplacingCharactersInRange(startIndex ..< endIndex, withString: string)
        return newString.characters.count <= 40
    }
    
    
    /* Helpers
    ------------------------------------------------------*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? VideoFeedViewController {
            videoFeedController = vc
            videoFeedController?.configureWithUser(user)
            if let story = story {
                videoFeedController?.configureStory(story)
            }
        }
        
        if let vc = segue.destinationViewController as? ChatFeedViewController {
            chatFeedController = vc
            vc.delegate = self
            chatFeedController?.configure(user)
        }
    }
    
}
