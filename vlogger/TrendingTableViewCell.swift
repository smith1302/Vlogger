//
//  TrendingTableViewCell.swift
//  vlogger
//
//  Created by Eric Smith on 1/15/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class TrendingTableViewCell: PFTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: PFImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var feedImageView: PFImageView!
    @IBOutlet weak var viewsLabel: UILabel!
    
    var story:Story!
    var video:Video! {
        willSet {
            if let video = newValue {
                self.feedImageView.image = video.getThumbnailImage()
                self.timeLabel.text = video.createdAt?.getReadableTimeDifference(NSDate())
            } else {
                self.timeLabel.text = ""
            }
        }
    }
    var user:User!
    
    func configure(story:Story) {
        self.story = story
        self.user = story.user
        
        let videoQuery = story.videos.query()
        videoQuery.getFirstObjectInBackgroundWithBlock({
            (object:PFObject?, error:NSError?) in
            if let video = object as? Video {
                self.video = video
            }
        })
        
        nameLabel.text = user.username
        
        userImageView.image = UIImage(named: "Avatar.png")
        userImageView.file = user.picture
        userImageView.loadInBackground()
        userImageView.contentMode = .ScaleAspectFill
        userImageView.layer.cornerRadius = userImageView.frame.size.height/2
        userImageView.layer.masksToBounds = true
        userImageView.backgroundColor = UIColor.lightGrayColor()
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
        
        feedImageView.contentMode = .ScaleAspectFill
        feedImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        feedImageView.clipsToBounds = true
        feedImageView.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
        feedImageView.layer.borderWidth = 4
        
        viewsLabel.text = "\(story.views.pretty()) views"
    }
    
    override func drawRect(rect: CGRect) {
        userImageView.layer.cornerRadius = userImageView.frame.size.height/2
    }
}
