//
//  PushController.swift
//  vlogger
//
//  Created by Eric Smith on 1/31/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import Foundation
import Parse
import ParseUI

class PushController {
    // Set them up with push when they login
    class func subscribeToPush() {
        
        if #available(iOS 8.0, *) {
            let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        } else {
            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(types)
        }
        
        PFPush.subscribeToChannelInBackground(User.currentUser()!.objectId!) { (succeeded: Bool, error: NSError?) in
            if succeeded {
                User.currentUser()?.notifications = true
            } else {
                print("Couldnt subscribe to user channel with error = %@.\n", error)
            }
        }
    }
    
    class func unsubscribeToPush() {
        PFPush.unsubscribeFromChannelInBackground(User.currentUser()!.objectId!) { (succeeded: Bool, error: NSError?) in
            if succeeded {
                User.currentUser()?.notifications = false
            } else {
                print("Couldnt subscribe to user channel with error = %@.\n", error)
            }
        }
    }
    
    class func sendPushToSubscriberReceiver(user:User) {
        if let username = User.currentUser()!.username {
            let data = [
                "alert": "\(username) subscribed to you",
                "sound": "default",
                "title": Constants.appName
            ]
            let push = PFPush()
            push.setChannel(user.objectId)
            push.setData(data)
            push.sendPushInBackground()
        }
    }
}