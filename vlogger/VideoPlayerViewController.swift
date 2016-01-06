//
//  VideoPlayerViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/5/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VideoPlayerViewController: AVPlayerViewController {
    
    var videoPlayer:LoopingPlayer?
    
    init(url:NSURL) {
        super.init(nibName: nil, bundle: nil)
        videoPlayer = LoopingPlayer(URL: url)
        self.player = videoPlayer!
        self.showsPlaybackControls = false
        self.view.frame = view.frame
        self.view.hidden = false
        self.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPlayer!.play()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
