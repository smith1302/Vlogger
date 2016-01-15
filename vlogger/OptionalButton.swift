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
    func didConfirmDelete()
    func didCancelDelete()
    func flagVideo()
}

class OptionalButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hidden = true
    }
    
    enum State:Int {
        case Delete
        case Flag
    }
    var video:Video!
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

    func configure(user:User) {
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
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this video?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
            self.delegate?.didCancelDelete()
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            self.delegate?.didConfirmDelete()
        }))
        
        self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
    }

}
