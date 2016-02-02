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
    @IBOutlet weak var rightSideLabel: UILabel!
    let loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var story:Story!
    var video:Video! {
        willSet {
            if let video = newValue {
//                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
//                    var image:UIImage?
//                    if let thumbnail = video.thumbnail {
//                        image = thumbnail
//                    } else {
//                        image = video.getThumbnailImage()
//                    }
//                    dispatch_async(dispatch_get_main_queue()){
//                        [weak self] in
//                        if let weakSelf = self {
//                            weakSelf.pfImageView.image = image
//                            weakSelf.loadingIndicator.stopAnimating()
//                        }
//                    }
//                }
                self.rightSideLabel.text = video.createdAt?.getReadableTime()
            } else {
                self.pfImageView.image = UIImage(named: "Avatar.png")
                self.rightSideLabel.text = ""
            }
        }
    }
    var user:User!
    
    func configureWithUser(story:Story) {
        self.story = story
        self.user = story.user
        commonConfigure()
    }
    
    func commonConfigure() {
        backgroundColor = UIColor.whiteColor()
        pfImageView.image = nil
        
        nameLabel.text = user.username
        
        loadingIndicator.removeFromSuperview()
        loadingIndicator.startAnimating()
        
        pfImageView.contentMode = .ScaleAspectFill
        pfImageView.layer.cornerRadius = pfImageView.frame.size.height/2
        pfImageView.layer.masksToBounds = true
        pfImageView.backgroundColor = UIColor.lightGrayColor()
        pfImageView.layer.borderWidth = 2
        pfImageView.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
        pfImageView.addSubview(loadingIndicator)
        pfImageView.image = UIImage(named: "Avatar.png")
        pfImageView.file = story.thumbnail
        pfImageView.loadInBackground({
            (image:UIImage?, error:NSError?) in
            self.loadingIndicator.stopAnimating()
        })
        
        rightSideLabel.text = story.videoAddedAt.getReadableTime()
    }
    
    override func drawRect(rect: CGRect) {
        pfImageView.layer.cornerRadius = pfImageView.frame.size.height/2
        loadingIndicator.frame = pfImageView.bounds
    }

}
