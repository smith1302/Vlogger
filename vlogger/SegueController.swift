//
//  SegueController.swift
//  vlogger
//
//  Created by Eric Smith on 1/26/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

enum SegueStyle {
    case swipeLeft
    case swipeRight
    case swipeDown
    case swipeUp
    case fadeIn
}

class SegueController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let segueStyle:SegueStyle
    
    init(segueStyle:SegueStyle) {
        self.segueStyle = segueStyle
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
            return 0.35
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if segueStyle == .fadeIn {
            fadeIn(transitionContext)
        } else if segueStyle == .swipeDown {
            
        } else if segueStyle == .swipeUp {
            
        } else if segueStyle == .swipeLeft {
            swipeLeft(transitionContext)
        } else if segueStyle == .swipeRight {
            swipeRight(transitionContext)
        } else {
            fadeIn(transitionContext)
        }
    }
    
    func fadeIn(transitionContext: UIViewControllerContextTransitioning) {
        if let containerView = transitionContext.containerView() {
            _ = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            
            containerView.addSubview(toVC!.view)
            toVC!.view.alpha = 0.0
            
            let duration = transitionDuration(transitionContext)
            UIView.animateWithDuration(duration, animations: {
                toVC!.view.alpha = 1.0
                }, completion: { finished in
                    let cancelled = transitionContext.transitionWasCancelled()
                    transitionContext.completeTransition(!cancelled)
            })
        }
    }
    
    func swipeLeft(transitionContext: UIViewControllerContextTransitioning) {
        if let containerView = transitionContext.containerView() {
            let fromController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            let toController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let fromVC = fromController.view!
            let toVC = toController.view!
            let initialToFrame = toVC.frame
            let intitialFromFrame = fromVC.frame
            
            let width = containerView.frame.size.width
            containerView.addSubview(toVC)
            containerView.addSubview(fromVC)
            toVC.frame.offsetInPlace(dx: width, dy: 0)
            
            let duration = transitionDuration(transitionContext)
            UIView.animateWithDuration(duration, animations: {
                toVC.frame = fromVC.frame
                fromVC.frame.offsetInPlace(dx: -width, dy: 0)
                }, completion: { finished in
                    let cancelled = transitionContext.transitionWasCancelled()
                    if cancelled {
                        toVC.frame = initialToFrame
                        fromVC.frame = intitialFromFrame
                    }
                    transitionContext.completeTransition(!cancelled)
            })
        }
    }
    
    func swipeRight(transitionContext: UIViewControllerContextTransitioning) {
        if let containerView = transitionContext.containerView() {
            let fromController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            let toController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let fromVC = fromController.view!
            let toVC = toController.view!
            let initialToFrame = toVC.frame
            let intitialFromFrame = fromVC.frame
            
            let width = containerView.frame.size.width
            containerView.addSubview(toVC)
            containerView.addSubview(fromVC)
            toVC.frame.offsetInPlace(dx: -width, dy: 0)
            
            let duration = transitionDuration(transitionContext)
            UIView.animateWithDuration(duration, animations: {
                toVC.frame = fromVC.frame
                fromVC.frame.offsetInPlace(dx: width, dy: 0)
                }, completion: { finished in
                    let cancelled = transitionContext.transitionWasCancelled()
                    if cancelled {
                        toVC.frame = initialToFrame
                        fromVC.frame = intitialFromFrame
                    }
                    transitionContext.completeTransition(!cancelled)
            })
        }
    }
}
