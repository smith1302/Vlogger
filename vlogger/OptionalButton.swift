//
//  OptionalButton.swift
//  vlogger
//
//  Created by Eric Smith on 1/12/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

protocol OptionalButtonDelegate:class {
    func didTapDelete()
    func didConfirmDeleteStory()
    func didConfirmDeleteSnap()
    func didCancelDelete()
    func flagVideo()
}

class OptionalButton: UIButtonOutline {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hidden = true
    }
    
    enum State:Int {
        case Delete
        case Flag
    }
    var user:User!
    var story:Story!
    weak var delegate:OptionalButtonDelegate?
    
    var buttonState:State! = State.Flag {
        willSet {
            enabled = false
            if newValue == State.Flag {
                setImage(UIImage(named: "Flag.png"), forState: .Normal)
            } else {
                setImage(UIImage(named: "Delete.png"), forState: .Normal)
            }
        }
        didSet {
            enabled = true
        }
    }

    func configure(user:User, story:Story) {
        self.user = user
        self.story = story
        hidden = false
        if user.objectId == User.currentUser()!.objectId {
            buttonState = State.Delete
        } else {
            buttonState = State.Flag
        }
        addTarget(self, action: "clicked", forControlEvents: .TouchUpInside)
    }
    
    func hide() {
        enabled = false
        hidden = true
    }
    
    func clicked() {
        if buttonState == State.Delete {
            delegate?.didTapDelete()
            confirmationAlert()
        } else {
            delegate?.flagVideo()
            MessageHandler.easyAlert("Reported", message: "This video has been reported.")
        }
    }
    
    func confirmationAlert() {
        let alert = UIAlertController(title: "Delete", message: "What would you like to delete?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            self.delegate?.didCancelDelete()
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // Dont want to delete snap for users active video
        var isActiveStory:Bool = true
        if let ID = user.currentStory?.objectId where ID != story.objectId! {
            isActiveStory = false
        }
        alert.addAction(UIAlertAction(title: "Delete Snap", style: (isActiveStory) ? .Destructive : .Default, handler: { (action: UIAlertAction!) in
            self.delegate?.didConfirmDeleteSnap()
        }))
        
        if !isActiveStory {
            alert.addAction(UIAlertAction(title: "Delete Story", style: .Destructive, handler: { (action: UIAlertAction!) in
                self.delegate?.didConfirmDeleteStory()
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
        }
        
        self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
    }

}
