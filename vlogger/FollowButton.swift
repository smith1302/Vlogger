//
//  FollowButton.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class FollowButton: UIButton {
    
    var following:Bool = false
    var user:User?
    
    override internal var enabled: Bool {
        willSet {
            if newValue == true {
                alpha = 1
            } else {
                alpha = 0.5
            }
        }
    }
    
    func configure(user:User) {
        setFollow()
        enabled = false
        if user.isUs() {
            return
        }
        User.currentUser()!.isFollowingUser(user, callback: {
            (isFollowing:Bool) in
            self.enabled = true
            if isFollowing {
                self.setUnfollow()
            } else {
                self.setFollow()
            }
        })
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func setFollow() {
        following = false
        setTitle("Follow", forState: .Normal)
    }
    
    func setUnfollow() {
        following = true
        setTitle("Unfollow", forState: .Normal)
    }

}
