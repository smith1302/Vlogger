//
//  FollowingTableViewCell.swift
//  vlogger
//
//  Created by Eric Smith on 1/10/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class FollowingTableViewCell: PFTableViewCell {


    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pfImageView: PFImageView!
    
    var following:Bool = false
    var user:User!
    
    func configure(user:User) {
        pfImageView.layer.cornerRadius = pfImageView.frame.size.height/2
        
        self.user = user
        let isFollowing = User.currentUser()!.isFollowingUser(user)
        setFollow(isFollowing)
        nameLabel.text = user.username
        pfImageView.file = user.picture
        pfImageView.loadInBackground()
    }
    
    func setFollow(isFollowing:Bool) {
        self.following = isFollowing
        if following {
            self.accessoryView = nil
            self.accessoryType = .Checkmark
        } else {
            self.accessoryType = .None
            let button = UIButton(type: .ContactAdd)
            button.addTarget(self, action: "followUser", forControlEvents: .TouchUpInside)
            self.accessoryView = button
            
        }
    }
    
    func followUser() {
        self.user.followUser()
        setFollow(true)
    }
}
