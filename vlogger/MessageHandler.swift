//
//  MessageHandler.swift
//  Selfiesteem
//
//  Created by Eric Smith on 11/26/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import UIKit

class MessageHandler {
    static var errorWindow: UIWindow?
    static var errorWindowLabel:UILabel!
    static let defaultTime:NSTimeInterval = 4
    static let height:CGFloat = 30
    static let animateDur:NSTimeInterval = 0.4
    
    class func easyAlert(title: String, message: String) {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    static func showMessage(text:String, withDuration:NSTimeInterval) {
        
        if errorWindow == nil {
            let keyWindow = UIApplication.sharedApplication().keyWindow!
            errorWindow = UIWindow(frame: CGRectMake(0, 0, keyWindow.frame.size.width, height))
            errorWindow?.backgroundColor = UIColor.clearColor()
            
            let errorView = UIView(frame: CGRectMake(0, 0, keyWindow.frame.size.width, height))
            errorView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.7)
            
            errorWindowLabel = UILabel(frame: CGRectMake(0, 0, keyWindow.frame.size.width, height))
            errorWindowLabel.text = text
            errorWindowLabel.textColor = UIColor.whiteColor()
            errorWindowLabel.font = UIFont.systemFontOfSize(height*0.5)
            errorWindowLabel.textAlignment = NSTextAlignment.Center
            
            errorView.addSubview(errorWindowLabel)
            errorWindow!.addSubview(errorView)
            errorWindow!.windowLevel = UIWindowLevelStatusBar+1
            errorWindow!.makeKeyAndVisible()
            
            errorWindow!.transform = CGAffineTransformMakeTranslation(0, -1*height)
            
            // Animate into place
            UIView.animateWithDuration(animateDur,
                animations: {
                    errorWindow!.transform = CGAffineTransformMakeTranslation(0, 0)
                },
                completion: {
                    finished in
                    // hide message after time is up
                    self.hideMessage(withDuration)
            })
            
        } else {
            errorWindowLabel.text = text
            UIView.animateWithDuration(animateDur,
                animations: {
                    errorWindow!.transform = CGAffineTransformMakeTranslation(0, 0)
                },
                completion: {
                    finished in
                    // hide message after time is up
                    self.hideMessage(withDuration)
            })
        }
    }
    
    static func showMessage(text:String) {
        showMessage(text, withDuration: defaultTime)
    }
    
    class func hideMessage(delay:NSTimeInterval) {
        UIView.animateWithDuration(animateDur, delay: delay, options: [],
            animations: {
                if errorWindow != nil {
                    errorWindow!.transform = CGAffineTransformMakeTranslation(0, -height)
                }
            }, completion: nil)
    }

}