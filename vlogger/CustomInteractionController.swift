//  CustomInteractionController.swift
//  CustomTransitions
//
//  Created by Joyce Echessa on 3/10/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

protocol CustomInteractionControllerDelegate:class {
    func transitionTriggeredByGesture()
    func interactionComplete()
}

class CustomInteractionController: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {
    
    var interactive = false
    var panGesture : UIPanGestureRecognizer!
    weak var delegate: CustomInteractionControllerDelegate?
    
    var sourceViewController : UIViewController! {
        didSet {
            panGesture = UIPanGestureRecognizer(target: self, action: "gestureHandler:")
            panGesture.delegate = self
            sourceViewController.view.addGestureRecognizer(panGesture)
        }
    }
    var segueIdentifierSwipeRight:String?
    var segueIdentifierSwipeLeft:String?
    
    func gestureHandler(pan : UIPanGestureRecognizer) {
        let translation = pan.translationInView(pan.view!)
        let d =  translation.x / pan.view!.bounds.width
        switch pan.state {
            case UIGestureRecognizerState.Began :
                delegate?.transitionTriggeredByGesture()
                if let swipeRight = segueIdentifierSwipeRight where d > 0 {
                    sourceViewController.performSegueWithIdentifier(swipeRight, sender: self)
                } else if let swipeLeft = segueIdentifierSwipeLeft where d < 0 {
                    sourceViewController.performSegueWithIdentifier(swipeLeft, sender: self)
                }
            case UIGestureRecognizerState.Changed :
                self.updateInteractiveTransition(abs(d))
            default:
                delegate?.interactionComplete()
                let finishGoal:CGFloat = 0.2
                if (d < finishGoal && d > -finishGoal) || pan.state == .Cancelled {
                    cancelInteractiveTransition()
                } else {
                    finishInteractiveTransition()
                }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let view = touch.view where view.isKindOfClass(UIButton) {
            return false
        }
        return true
    }
}