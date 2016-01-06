//
//  FeedViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/5/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Parse

class FeedViewController: UIViewController {
    
    var videos:[Video] = [Video]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = User.currentUser()!
        user.getVideos({
            (videos:[Video]) in
            self.videos = videos
            var selected:Video?
            for video in videos {
                selected = video
            }
            self.displayVideo(selected)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayVideo(video:Video?) {
        if video == nil {
            return
        }
        if let url = video?.getFileURL() {
            let videoPlayerController = VideoPlayerViewController(url: url)
            videoPlayerController.view.frame = view.frame
            self.addChildViewController(videoPlayerController)
            self.view.addSubview(videoPlayerController.view)
        }
    }

}
