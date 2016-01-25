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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var feedImageView: PFImageView!
    @IBOutlet weak var userImageView: PFImageView!
    let loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var story:Story!
    var video:Video! {
        willSet {
            if let video = newValue {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    var image:UIImage?
                    if let thumbnail = video.thumbnail {
                        image = thumbnail
                    } else {
                        image = video.getThumbnailImage()
                        video.thumbnail = image
                    }
                    dispatch_async(dispatch_get_main_queue()){
                        [weak self] in
                        if let weakSelf = self {
                            UIView.animateWithDuration(1, animations: {
                                weakSelf.feedImageView.image = image
                            })
                            weakSelf.loadingIndicator.stopAnimating()
                        }
                    }
                }
                //self.timeLabel.text = ""
            } else {
                //self.timeLabel.text = ""
            }
        }
    }
    var user:User!
    
    func configure(story:Story) {
        
        feedImageView.image = nil
        
        self.story = story
        self.user = story.user
        
        let videoQuery = story.videos.query()
        videoQuery.getFirstObjectInBackgroundWithBlock({
            (object:PFObject?, error:NSError?) in
            if let video = object as? Video {
                self.video = video
            }
        })
        
        //self.timeLabel.text = ""
        titleLabel.text = story.title
        titleLabel.textAlignment = .Center
        nameLabel.text = user.username
        
        userImageView.image = UIImage(named: "Avatar.png")
        userImageView.file = user.picture
        userImageView.loadInBackground()
        userImageView.contentMode = .ScaleAspectFill
        userImageView.layer.cornerRadius = userImageView.frame.size.height/2
        userImageView.layer.masksToBounds = true
        userImageView.backgroundColor = UIColor.lightGrayColor()
        userImageView.layer.borderWidth = 0
        userImageView.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
        
        loadingIndicator.removeFromSuperview()
        loadingIndicator.startAnimating()
        
        feedImageView.contentMode = .ScaleAspectFill
        feedImageView.backgroundColor = UIColor(white: 0.5, alpha: 1)
        feedImageView.clipsToBounds = true
        feedImageView.layer.borderColor = UIColor(white: 0.6, alpha: 1).CGColor
        feedImageView.layer.borderWidth = 1
        feedImageView.addSubview(loadingIndicator)
        
        //viewsLabel.text = "\(story.views.pretty()) views"
    }
    
    override func drawRect(rect: CGRect) {
        userImageView.layer.cornerRadius = userImageView.frame.size.height/2
        loadingIndicator.frame = feedImageView.bounds
    }
}
