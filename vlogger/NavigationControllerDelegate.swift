//
//  NavigationControllerDelegate.swift
//  vlogger
//
//  Created by Eric Smith on 1/26/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

enum SwipeDirection {
    case Left
    case Right
}

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, CustomInteractionControllerDelegate {

    private let interactionController = CustomInteractionController()
    private var useInteractionController:Bool = false
    
    override init() {
        super.init()
        interactionController.delegate = self
    }
    
    func addSwipableController(controller:UIViewController) {
        interactionController.sourceViewController = controller
    }
    
    func addDirectionSegue(swipeLeft segueIdentifierSwipeLeft:String?, swipeRight segueIdentifierSwipeRight:String?) {
        interactionController.segueIdentifierSwipeLeft = segueIdentifierSwipeLeft
        interactionController.segueIdentifierSwipeRight = segueIdentifierSwipeRight
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation:UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) ->UIViewControllerAnimatedTransitioning? {
        
        let swipeLeftCondition = (fromVC.isKindOfClass(VideoViewController) && toVC.isKindOfClass(ProfileViewController))
                                 || (fromVC.isKindOfClass(HomeViewController) && toVC.isKindOfClass(VideoViewController))
        
        let swipeRightCondition = (fromVC.isKindOfClass(VideoViewController) && toVC.isKindOfClass(HomeViewController))
                                  || (fromVC.isKindOfClass(ProfileViewController) && toVC.isKindOfClass(VideoViewController))
        
        if swipeLeftCondition{
            return SegueController(segueStyle: SegueStyle.swipeLeft)
        } else if swipeRightCondition {
            return SegueController(segueStyle: SegueStyle.swipeRight)
        } else {
            return nil
        }
    }
    
    func transitionTriggeredByGesture() {
        self.useInteractionController = true
    }
    
    func interactionComplete() {
        self.useInteractionController = false
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SegueController(segueStyle: SegueStyle.swipeRight)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SegueController(segueStyle: SegueStyle.swipeRight)
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (useInteractionController) ? interactionController : nil
    }
}
