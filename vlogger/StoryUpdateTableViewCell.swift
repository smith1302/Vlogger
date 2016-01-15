//
//  StoryUpdateTableViewCell.swift
//  vlogger
//
//  Created by Eric Smith on 1/12/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class StoryUpdateTableViewCell: PFTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pfImageView: PFImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var videoUpdate:VideoUpdates!
    var video:Video! {
        willSet {
            if let video = newValue {
                self.pfImageView.image = video.getThumbnailImage()
                self.timeLabel.text = video.createdAt?.getReadableTimeDifference(NSDate())
            } else {
                self.pfImageView.image = UIImage(named: "Avatar.png")
                self.timeLabel.text = ""
            }
        }
    }
    var user:User!
    
    func configure(videoUpdate:VideoUpdates) {
        self.videoUpdate = videoUpdate
        self.video = videoUpdate.video
        self.user = videoUpdate.user
        
        nameLabel.text = user.username
        
        pfImageView.contentMode = .ScaleAspectFill
        pfImageView.layer.cornerRadius = pfImageView.frame.size.height/2
        pfImageView.layer.masksToBounds = true
        pfImageView.backgroundColor = UIColor.lightGrayColor()
        pfImageView.layer.borderWidth = 4
        pfImageView.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
    }
    
    override func drawRect(rect: CGRect) {
        pfImageView.layer.cornerRadius = pfImageView.frame.size.height/2
    }

}
