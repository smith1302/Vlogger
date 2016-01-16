//
//  ProfileTableViewCell.swift
//  vlogger
//
//  Created by Eric Smith on 1/15/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class ProfileTableViewCell: PFTableViewCell {

    @IBOutlet weak var pfImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    var story:Story!
    var video:Video! {
        willSet {
            if let video = newValue {
                self.pfImageView.image = video.getThumbnailImage()
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
        
        titleLabel.text = NSDate.getReadableTimeFromDay(story.day)
        
        pfImageView.contentMode = .ScaleAspectFill
        pfImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        pfImageView.clipsToBounds = true
        pfImageView.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
        pfImageView.layer.borderWidth = 2
        
        viewsLabel.text = "\(story.views.pretty()) views"
    }
    
}
