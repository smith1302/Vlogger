//
//  Utilities.swift
//  vlogger
//
//  Created by Eric Smith on 1/8/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

enum VersionLaunchType {
    case freshInstall
    case updatedVersion
    case sameVersion
}

class Utilities {
    class func autolayoutSubviewToViewEdges(subview:UIView, view:UIView, edgeInsets:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: edgeInsets.top))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: edgeInsets.left))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: edgeInsets.right))
        view.addConstraint(NSLayoutConstraint(item: subview, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: edgeInsets.bottom))
    }

    class func setAudioSessionCategory(category:String) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(category)
            try audioSession.setActive(true)
        } catch {}
    }
    
    class func springAnimation(view:UIView, completion:(Void->Void)?) {
        view.transform = CGAffineTransformMakeScale(0.001,0.001)
        UIView.animateWithDuration(1,
            delay: 0.2,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 0.8,
            options: .CurveEaseInOut,
            animations: {
                view.transform = CGAffineTransformMakeScale(1, 1)
            },
            completion: {
                finished in
                completion?()
        })
    }
    
    class func getUsersAppVersion() -> VersionLaunchType {
        let defaults = NSUserDefaults.standardUserDefaults()
        let currentAppVersion = Utilities.getCurrentAppVersion()
        let previousVersion = defaults.stringForKey("appVersion")
        if previousVersion == nil {
            Utilities.updateUsersAppVersion()
            return VersionLaunchType.freshInstall
        } else if previousVersion == currentAppVersion {
            return VersionLaunchType.sameVersion
        } else {
            Utilities.updateUsersAppVersion()
            return VersionLaunchType.updatedVersion
        }
    }
    
    class func updateUsersAppVersion() {
        let currentAppVersion = Utilities.getCurrentAppVersion()
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(currentAppVersion, forKey: "appVersion")
        defaults.synchronize()
    }
    
    class func getCurrentAppVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
}