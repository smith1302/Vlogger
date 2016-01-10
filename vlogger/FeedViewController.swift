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

class FeedViewController: UIViewController, VideoFeedViewControllerDelegate, ProfileCardViewControllerDelegate {
    
    @IBOutlet weak var chatDragTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatDragView: UIView!
    
    var profileCardViewController:ProfileCardViewController?
    
    var topDragLimit:CGFloat!
    var bottomDragLimit:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled = true
        
        topDragLimit = 150
        bottomDragLimit = view.frame.size.height-chatDragView.frame.size.height-100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func chatDrag(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.view)
        let newY = sender.view!.frame.origin.y + translation.y
        
        chatDragTopConstraint.constant = newY
        sender.setTranslation(CGPointZero, inView: self.view)
        view.layoutIfNeeded()
        
        if sender.state == .Ended {
            chatDragRelease(chatDragView)
        }
    }

    func chatDragRelease(sender: UIView) {
        let y = sender.center.y
        let height = sender.frame.size.height
        if y < topDragLimit {
            animateChatDraggerToConstraintConstant(0)
        } else if y > bottomDragLimit {
            animateChatDraggerToConstraintConstant(view.frame.size.height-height)
        }
    }
    
    func animateChatDraggerToConstraintConstant(constant:CGFloat) {
        chatDragTopConstraint.constant = constant
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    /* VideoFeedViewControllerDelegate
    ------------------------------------------------------*/
    
    func showProfileCard() {
        if profileCardViewController != nil {
            return
        }
        
        let storyboard = self.storyboard
        if let vc = storyboard?.instantiateViewControllerWithIdentifier("ProfileCardViewController") as? ProfileCardViewController {
            self.profileCardViewController = vc
            addChildViewController(vc)
            view.addSubview(vc.view)
            vc.view.frame = view.frame
            vc.delegate = self
        }
    }
    
    /* VideoFeedViewControllerDelegate
    ------------------------------------------------------*/
    
    func profileCardClosed() {
        profileCardViewController = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? VideoFeedViewController {
            vc.delegate = self
        }
    }
    
}
