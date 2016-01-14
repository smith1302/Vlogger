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
    
    var video:Video!
    
    func configure(video:Video) {
        self.video = video
        let user = video.user
        nameLabel.text = user.username
        
        pfImageView.file = user.picture
        pfImageView.contentMode = .ScaleAspectFill
        pfImageView.image = video.getThumbnailImage()
        pfImageView.loadInBackground()
        pfImageView.layer.cornerRadius = pfImageView.frame.size.height/2
        pfImageView.layer.masksToBounds = true
        pfImageView.backgroundColor = UIColor.lightGrayColor()
        pfImageView.layer.borderWidth = 4
        pfImageView.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
        
        timeLabel.text = video.createdAt?.getReadableTimeDifference(NSDate())
    }
    
    override func drawRect(rect: CGRect) {
        pfImageView.layer.cornerRadius = pfImageView.frame.size.height/2
    }

}
