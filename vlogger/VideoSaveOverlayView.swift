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
    func addVideoToNewStoryPressed(title:String)
    func addVideoToCurrentStoryPressed()
}

class VideoSaveOverlayView: UIViewController, AddVideoToStoryViewDelegate, UITextFieldDelegate {
    
    let xButton:UIButtonOutline
    let nextButton:UIButton
    var delegate:VideoSaveOverlayDelegate?
    var addVideoToStoryView:AddVideoToStoryView?

    init(frame: CGRect) {
        
        let xPadding:CGFloat = 12
        let xSize:CGFloat = 28+xPadding*2
        let xImage = UIImage(named: "X.png")
        xButton = UIButtonOutline(image: xImage!, frame: CGRectMake(0, 0, xSize, xSize))
        xButton.imageView?.contentMode = .ScaleAspectFit
        xButton.imageEdgeInsets = UIEdgeInsets(top: xPadding, left: xPadding, bottom: xPadding, right: xPadding)
        xButton.alpha = 0.8
        
        let nextPadding:CGFloat = 25
        let nextSize:CGFloat = 35+nextPadding*2
        let nextImage = UIImage(named: "Check.png")
        nextButton = UIButton(frame: CGRectMake(frame.size.width/2-nextSize/2, frame.size.height-nextSize-nextPadding, nextSize, nextSize))
        nextButton.setImage(nextImage, forState: .Normal)
        nextButton.imageView?.contentMode = .ScaleAspectFit
        nextButton.imageEdgeInsets = UIEdgeInsets(top: nextPadding, left: nextPadding, bottom: nextPadding, right: nextPadding)
        nextButton.backgroundColor = Constants.primaryColor
        nextButton.layer.cornerRadius = nextButton.frame.height/2
        
        super.init(nibName: nil, bundle: nil)
        
        xButton.addTarget(self, action: "cancelPressed", forControlEvents: .TouchUpInside)
        nextButton.addTarget(self, action: "continuePressed", forControlEvents: .TouchUpInside)
        
        view.addSubview(xButton)
        view.addSubview(nextButton)
        
        Utilities.springAnimation(nextButton, completion: nil)
        
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
        
        addVideoToStoryView = AddVideoToStoryView(frame: view.bounds)
        addVideoToStoryView?.delegate = self
        view.addSubview(addVideoToStoryView!)
        addVideoToStoryView!.transform = CGAffineTransformMakeTranslation(0, addVideoToStoryView!.frame.size.height)
        
        let time:NSTimeInterval = 0.4
        
        UIView.animateWithDuration(time, animations: {
           self.addVideoToStoryView!.transform = CGAffineTransformMakeTranslation(0, 0)
        })
        
        UIView.animateWithDuration(time*0.3, animations: {
                self.nextButton.transform = CGAffineTransformMakeScale(0.01, 0.01)
            }, completion: {
                finished in
                self.nextButton.removeFromSuperview()
        })
    }
    
    var newStoryNameField:UITextField?
    var OKAction:UIAlertAction?
    func newStoryConfirmation() {
        let alertController = UIAlertController(title: "Story Name", message: "You can always change this later.", preferredStyle: .Alert)
        OKAction = UIAlertAction(title: "Post", style: .Default, handler: {
            (action:UIAlertAction) in
            if let text = self.newStoryNameField?.text where text.characters.count > 0 && !text.isEmpty {
                self.submitToNewStory()
            }
        })
        OKAction!.enabled = false
        alertController.addAction(OKAction!)
        
        alertController.addTextFieldWithConfigurationHandler({
            (textField:UITextField) in
            textField.placeholder = "Story name"
            textField.delegate = self
            textField.returnKeyType = UIReturnKeyType.Done
            textField.addTarget(self, action: "textFieldChanged", forControlEvents: UIControlEvents.EditingChanged)
            self.newStoryNameField = textField
        })
        
        let cancel = UIAlertAction(title: "No", style: .Cancel, handler: nil)
        alertController.addAction(cancel)

        self.parentViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func submitToCurrentStory() {
        remove()
        delegate?.addVideoToCurrentStoryPressed()
    }
    
    func submitToNewStory() {
        if let text = self.newStoryNameField?.text {
            remove()
            delegate?.addVideoToNewStoryPressed(text)
        }
    }
    
    func remove() {
        UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseIn, animations: {
            if let view = self.addVideoToStoryView {
                view.transform = CGAffineTransformMakeTranslation(0, view.frame.size.height)
                view.alpha = 0
            }
            }, completion: {
                (finished) in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* Title Text Field
    ------------------------------------------------------*/
    
    func textFieldChanged() {
        if let text = self.newStoryNameField?.text where text.characters.count == 0 || text.isEmpty {
            OKAction?.enabled = false
        } else {
            OKAction?.enabled = true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldString = textField.text ?? ""
        let startIndex = oldString.startIndex.advancedBy(range.location)
        let endIndex = startIndex.advancedBy(range.length)
        let newString = oldString.stringByReplacingCharactersInRange(startIndex ..< endIndex, withString: string)
        return newString.characters.count <= 40
    }
    
    /* Add story view delegate
    ---------------------------------------------------------------*/
    
    func newStoryClicked() {
        newStoryConfirmation()
    }
    
    func addStoryClicked() {
        submitToCurrentStory()
    }

}
