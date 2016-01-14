//
//  LikeButton.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

protocol LikeButtonDelegate:class {
    func didLikeVideo()
    func didUnlikeVideo()
}

class LikeButton: UIButton {
    
    enum LikeState {
        case Liked
        case Unliked
    }
    var video:Video!
    weak var delegate:LikeButtonDelegate?
    
    var likeState:LikeState! = LikeState.Unliked {
        willSet {
            enabled = false
            if newValue == LikeState.Liked {
                setImage(UIImage(named: "Like-Full.png"), forState: .Normal)
            } else {
                setImage(UIImage(named: "Like-Empty.png"), forState: .Normal)
            }
        }
        didSet {
            enabled = true
        }
    }
    
    override internal var enabled: Bool {
        willSet {
            if newValue == true {
                alpha = 0.85
            } else {
                alpha = 0.6
            }
        }
    }
    
    func configure(video:Video?) {
        self.video = video
        enabled = false
        if let video = video {
            addTarget(self, action: "clicked", forControlEvents: .TouchUpInside)
            User.currentUser()!.hasLikedVideo(video, callback: {
                (hasLiked:Bool) in
                self.enabled = true
                if hasLiked {
                    self.likeState = LikeState.Liked
                } else {
                    self.likeState = LikeState.Unliked
                }
            })
        }
    }
    
    func clicked() {
        if likeState == LikeState.Liked && video.unlike() {
            likeState = LikeState.Unliked
            delegate?.didUnlikeVideo()
        } else if video.like() {
            likeState = LikeState.Liked
            delegate?.didLikeVideo()
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
