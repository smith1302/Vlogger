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
        setFollow(false, enabled: false)
        self.user = user
        nameLabel.text = user.username
        
        pfImageView.file = user.picture
        pfImageView.image = UIImage(named: "Avatar.png")
        pfImageView.loadInBackground()
        pfImageView.layer.cornerRadius = pfImageView.frame.size.height/2
        pfImageView.layer.masksToBounds = true
        pfImageView.backgroundColor = UIColor.lightGrayColor()
        pfImageView.layer.borderWidth = 4
        pfImageView.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
    }
    
    func setFollow(isFollowing:Bool, enabled:Bool) {
        self.following = isFollowing
        if following {
            self.accessoryView = nil
            self.accessoryType = .Checkmark
        } else {
            self.accessoryType = .None
            let button = UIButton(type: .ContactAdd)
            button.addTarget(self, action: "followUser", forControlEvents: .TouchUpInside)
            button.enabled = enabled
            self.accessoryView = button
        }
    }
    
    func followUser() {
        self.user.followUser()
        setFollow(true, enabled: true)
    }
    
    override func drawRect(rect: CGRect) {
        pfImageView.layer.cornerRadius = pfImageView.frame.size.height/2
    }
}
