//
//  ProfileTableViewCell.swift
//  vlogger
//
//  Created by Eric Smith on 1/15/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

protocol ProfileTableViewCellDelegate:class {
    func moreButtonClicked(indexPath:NSIndexPath)
}

class ProfileTableViewCell: PFTableViewCell {

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var pfImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    let loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    weak var delegate:ProfileTableViewCellDelegate?
    
    var indexPath:NSIndexPath!
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
                    }
                    dispatch_async(dispatch_get_main_queue()){
                        [weak self] in
                        if let weakSelf = self {
                            weakSelf.pfImageView.image = image
                            weakSelf.loadingIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
    }
    var user:User!
    
    func configure(story:Story, indexPath:NSIndexPath) {
        
        moreButton.hidden = true
        
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
        
        if user.isUs() && indexPath.section > 0 {
            moreButton.hidden = false
        }
        
        loadingIndicator.removeFromSuperview()
        loadingIndicator.startAnimating()
        
        let videoQuery = story.videos.query()
        videoQuery.getFirstObjectInBackgroundWithBlock({
            (object:PFObject?, error:NSError?) in
            if let video = object as? Video {
                self.video = video
            } else {
                self.loadingIndicator.stopAnimating()
            }
        })
        
        titleLabel.text = story.title
        
        pfImageView.image = nil
        pfImageView.contentMode = .ScaleAspectFill
        pfImageView.backgroundColor = UIColor(white: 0.8, alpha: 1)
        pfImageView.clipsToBounds = true
        pfImageView.layer.borderColor = UIColor(white: 0.74, alpha: 1).CGColor
        pfImageView.layer.borderWidth = 1
        pfImageView.addSubview(loadingIndicator)
        
        viewsLabel.text = "\(story.views.pretty()) views"
        
        // more button
        moreButton.setImage(UIImage(named: "DotMenu.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        moreButton.tintColor = UIColor(white: 0.7, alpha: 1)
    }
    
    override func drawRect(rect: CGRect) {
        loadingIndicator.frame = pfImageView.bounds
    }
    
    @IBAction func moreButtonClicked(sender: AnyObject) {
        delegate?.moreButtonClicked(self.indexPath)
    }
}
