//
//  VideoSaveOverlayView.swift
//  vlogger
//
//  Created by Eric Smith on 1/4/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

protocol VideoSaveOverlayDelegate {
    func cancelPressed()
    func addVideoToNewStoryPressed()
    func addVideoToCurrentStoryPressed()
}

class VideoSaveOverlayView: UIViewController {
    
    let xButton:UIButtonOutline
    let nextButton:UIButtonOutline
    let gradient:UIImageView
    let padding:CGFloat = 12
    var delegate:VideoSaveOverlayDelegate?

    init(frame: CGRect) {
        
        let xSize:CGFloat = 45+padding*2
        let xImage = UIImage(named: "X.png")
        xButton = UIButtonOutline(image: xImage!, frame: CGRectMake(0, frame.size.height-xSize, xSize, xSize))
        xButton.imageView?.contentMode = .ScaleAspectFit
        xButton.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        xButton.alpha = 0.8
        
        let nextSize:CGFloat = 45+padding*2
        let nextImage = UIImage(named: "Next.png")
        nextButton = UIButtonOutline(image: nextImage!, frame: CGRectMake(frame.size.width-nextSize, frame.size.height-nextSize, nextSize, nextSize))
        nextButton.imageView?.contentMode = .ScaleAspectFit
        nextButton.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        nextButton.alpha = 0.8
        
        let gradientHeight:CGFloat = nextSize
        gradient = UIImageView(image: UIImage(named: "gradient.png"))
        gradient.frame = CGRectMake(0, frame.size.height-gradientHeight, frame.size.width, gradientHeight)
        gradient.backgroundColor = UIColor(white: 0.1, alpha: 0.2)
        
        super.init(nibName: nil, bundle: nil)
        
        xButton.addTarget(self, action: "cancelPressed", forControlEvents: .TouchUpInside)
        nextButton.addTarget(self, action: "continuePressed", forControlEvents: .TouchUpInside)
        
        view.addSubview(gradient)
        view.addSubview(xButton)
        view.addSubview(nextButton)
        
        view.transform = CGAffineTransformMakeTranslation(0, gradientHeight)
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.view.transform = CGAffineTransformMakeTranslation(0, 0)
        }, completion: nil)
        
    }
    
    func cancelPressed() {
        remove()
        delegate?.cancelPressed()
    }
    
    func continuePressed() {
        if User.currentUser()!.currentStory == nil {
            submitToCurrentStory()
            return
        }
        let alertController = UIAlertController()
        let current = UIAlertAction(title: "Current Story", style: .Default, handler: {
            (action:UIAlertAction) in
            self.submitToCurrentStory()
        })
        alertController.addAction(current)
        let new = UIAlertAction(title: "Start a New Story", style: .Default, handler: {
            (action:UIAlertAction) in
            self.newStoryConfirmation()
        })
        alertController.addAction(new)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancel)
        
        self.parentViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func newStoryConfirmation() {
        let alertController = UIAlertController(title: "Are you sure?", message: "Your current story will be saved.", preferredStyle: .Alert)
        let OK = UIAlertAction(title: "Yes", style: .Default, handler: {
            (action:UIAlertAction) in
            self.submitToNewStory()
        })
        alertController.addAction(OK)
        let cancel = UIAlertAction(title: "No", style: .Cancel, handler: nil)
        alertController.addAction(cancel)

        self.parentViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func submitToCurrentStory() {
        remove()
        delegate?.addVideoToCurrentStoryPressed()
    }
    
    func submitToNewStory() {
        remove()
        delegate?.addVideoToNewStoryPressed()
    }
    
    func remove() {
        UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseIn, animations: {
            self.view.transform = CGAffineTransformMakeTranslation(0, self.gradient.frame.size.height)
            }, completion: {
                (finished) in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
