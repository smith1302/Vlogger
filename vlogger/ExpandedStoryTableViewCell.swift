//
//  ExpandedStoryTableViewCell
//  vlogger
//
//  Created by Eric Smith on 1/15/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class ExpandedStoryTableViewCell: PFTableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var feedImageView: PFImageView!
    @IBOutlet weak var userImageView: PFImageView!
    let loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var selectedView:UIView?
    
    var story:Story = Story()
//    var video:Video! {
//        willSet {
//            if let video = newValue {
//                var file = video.generateThumbnail()
//                story.thumbnail = file
//                file?.saveInBackgroundWithBlock({
//                    (success:Bool, error:NSError?) in
//                    if success {
//                        self.story.saveEventually({
//                            (success:Bool, error:NSError?) in
//                            if error != nil {
//                                print(error!)
//                            }
//                        })
//                    }
//                })
//            }
//        }
//    }
    var user:User!
    
    func configure(story:Story) {
        
        if let currentID = self.story.objectId, newID = story.objectId where newID == currentID {
            return
        }
        
        if selectedView == nil {
            selectedView = UIView()
            selectedView!.backgroundColor = UIColor(white: 0.95, alpha: 1)
            selectedBackgroundView = selectedView!
        }
        
        backgroundColor = UIColor.whiteColor()
        feedImageView.image = nil
        
        self.story = story
        self.user = story.user
        
        self.timeLabel.text = story.videoAddedAt.getReadableTime()
        
        self.timeLabel.text = ""
        self.timeLabel.backgroundColor = UIColor.clearColor()
        
        titleLabel.text = story.title
        titleLabel.textAlignment = .Center
        
        self.nameLabel.text = self.user.username
        self.nameLabel.backgroundColor = UIColor.clearColor()
        
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
        //feedImageView.backgroundColor = UIColor(white: 0.6, alpha: 1)
        feedImageView.clipsToBounds = true
        feedImageView.layer.borderColor = UIColor(white: 0.6, alpha: 1).CGColor
        feedImageView.layer.borderWidth = 1
        feedImageView.addSubview(loadingIndicator)
        story.getThumbnail({
            (image:UIImage?) in
            if let image = image {
                self.feedImageView.image = image
                self.titleLabel.backgroundColor = UIColor(hex: 0x00EAFF, alpha: 0.02)
                self.animateViewAlpha(self.feedImageView, alpha: 1)
            }
            self.loadingIndicator.stopAnimating()
        })
    }
    
    func animateViewAlpha(view:UIView, alpha:CGFloat) {
        view.alpha = 0
        UIView.animateWithDuration(0.5, animations: {
            view.alpha = alpha
        })
    }
    
    override func drawRect(rect: CGRect) {
        userImageView.layer.cornerRadius = userImageView.frame.size.height/2
        loadingIndicator.frame = feedImageView.bounds
    }
}
