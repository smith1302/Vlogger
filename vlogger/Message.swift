//
//  Message.swift
//  vlogger
//
//  Created by Eric Smith on 1/11/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import Foundation
import Firebase

let kMessageUserIDKey = "userID"
let kMessageUserNameKey = "userName"
let kMessageTextKey = "text"
let kMessageTimestamp = "timestamp"

class Message {
    let userID:String
    let userName:String
    let text:String
    let timestamp:NSDate
    let firebaseRef:Firebase
    
    init(userID:String, userName:String, text:String, timestamp:NSDate, firebaseRef:Firebase) {
        self.userID = userID
        self.userName = userName
        self.text = text
        self.timestamp = timestamp
        self.firebaseRef = firebaseRef
    }
    
    func send() {
        let messageData = [kMessageUserIDKey:userID,
                            kMessageUserNameKey:userName,
                            kMessageTextKey:text,
                            kMessageTimestamp:timestamp.timeIntervalSince1970]
        firebaseRef.childByAutoId().setValue(messageData)
    }
    
    func isOlderThanDate(date:NSDate) -> Bool {
        return timestamp.timeIntervalSinceDate(date).isSignMinus
    }
    
    class func extractMessageFromSnapshot(snapshot:FDataSnapshot, firebaseRef:Firebase) -> Message {
        let userID = snapshot.value[kMessageUserIDKey] as! String
        let userName = snapshot.value[kMessageUserNameKey] as! String
        let text = snapshot.value[kMessageTextKey] as! String
        let doubleTimestamp = (snapshot.value[kMessageTimestamp] as! NSNumber).doubleValue
        let timestamp = NSDate(timeIntervalSince1970: doubleTimestamp)
        let message = Message(userID: userID, userName: userName, text: text, timestamp: timestamp, firebaseRef: firebaseRef)
        return message
    }
}