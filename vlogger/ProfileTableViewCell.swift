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

    @IBOutlet weak var pfImageView: PFImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    let loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var selectedView:UIView?
    
    var dispatchedVideoID:String? = ""
    var indexPath:NSIndexPath!
    var story:Story = Story()
    var video:Video! {
        willSet {
//            if let video = newValue {
//                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
//                    self.dispatchedVideoID = video.objectId
//                    let workingVideoID = video.objectId
//                    var image:UIImage?
//                    if let thumbnail = video.thumbnail {
//                        image = thumbnail
//                    } else {
//                        image = video.getThumbnailImage()
//                    }
//                    dispatch_async(dispatch_get_main_queue()){
//                        [weak self] in
//                        if let weakSelf = self {
//                            if weakSelf.dispatchedVideoID == workingVideoID {
//                                weakSelf.pfImageView.image = image
//                                weakSelf.loadingIndicator.stopAnimating()
//                            }
//                        }
//                    }
//                }
//            }
        }
    }
    var user:User!
    
    func configure(story:Story, indexPath:NSIndexPath) {
        
        if let currentID = self.story.objectId, newID = story.objectId where newID == currentID {
            self.story = story
            self.user = story.user
            titleLabel.text = story.title
            viewsLabel.text = "\(story.views.pretty()) \("view".pluralize("s", basedOn: CGFloat(story.views)))"
            return
        }
        
        if selectedView == nil {
            selectedView = UIView()
            selectedView!.backgroundColor = UIColor(white: 0.95, alpha: 1)
            selectedBackgroundView = selectedView!
        }
        
        if !story.dataAvailable {
            story.fetchIfNeededInBackgroundWithBlock({
                (object:PFObject?, error:NSError?) in
                if let story = object as? Story {
                    self.configure(story, indexPath: indexPath)
                }
            })
            return
        }
        self.story = story
        self.user = story.user
        self.indexPath = indexPath
        
        loadingIndicator.removeFromSuperview()
        loadingIndicator.startAnimating()
        
//        let videoQuery = story.videos.query()
//        videoQuery.getFirstObjectInBackgroundWithBlock({
//            (object:PFObject?, error:NSError?) in
//            if let video = object as? Video {
//                self.video = video
//            } else {
//                self.loadingIndicator.stopAnimating()
//            }
//        })
        
        titleLabel.text = story.title
        titleLabel.textColor = UIColor(white: 0.3, alpha: 1)
        titleLabel.backgroundColor = UIColor.clearColor()
        
        pfImageView.image = nil
        pfImageView.contentMode = .ScaleAspectFill
        pfImageView.backgroundColor = UIColor(white: 0.8, alpha: 1)
        pfImageView.clipsToBounds = true
        pfImageView.layer.borderColor = UIColor(white: 0.74, alpha: 1).CGColor
        pfImageView.layer.borderWidth = 1
        pfImageView.addSubview(loadingIndicator)
        story.getThumbnail({
            (image:UIImage?) in
            if let image = image {
                self.pfImageView.image = image
            }
            self.loadingIndicator.stopAnimating()
        })
        
        viewsLabel.text = "\(story.views.pretty()) \("view".pluralize("s", basedOn: CGFloat(story.views)))"
        viewsLabel.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        loadingIndicator.frame = pfImageView.bounds
    }
}
