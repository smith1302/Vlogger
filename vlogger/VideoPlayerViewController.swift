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

protocol VideoPlayerViewControllerDelegate: class {
    func currentVideoChanged(_:Video?)
}

class VideoPlayerViewController: AVPlayerViewController, VideoProgressBarDelegate {
    
    //var progressBarController:VideoProgressBarViewController!
    var activityIndicator:ActivityIndicatorView!
    var videos:[Video] = [Video]()
    weak var myDelegate:VideoPlayerViewControllerDelegate?
    var currentVideo:Video? {
        didSet {
            myDelegate?.currentVideoChanged(self.currentVideo)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init(frame:CGRect) {
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    init(videos:[Video]) {
        super.init(nibName: nil, bundle: nil)
        commonInit()
        setVideos(videos)
    }
    
    init(user:User) {
        super.init(nibName: nil, bundle: nil)
        commonInit()
        user.getVideos({
            (videos:[Video]) in
            self.setVideos(videos)
        })
    }
    
    func commonInit() {
        self.showsPlaybackControls = false
        self.view.hidden = false
        self.videoGravity = AVLayerVideoGravityResizeAspectFill
        //self.progressBarController = VideoProgressBarViewController()
        //self.progressBarController.delegate = self
        //self.addChildViewController(progressBarController)
        
        // Align contentoverlay with entire view
        contentOverlayView!.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: contentOverlayView!, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: contentOverlayView!, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: contentOverlayView!, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: contentOverlayView!, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        
        contentOverlayView?.userInteractionEnabled=true
        
        //contentOverlayView?.addSubview(progressBarController.view)
        
        // Activity Indicator View
        activityIndicator = ActivityIndicatorView(frame: contentOverlayView!.bounds)
        activityIndicator.startAnimating()
        contentOverlayView?.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentOverlayView!.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .Top, relatedBy: .Equal, toItem: contentOverlayView!, attribute: .Top, multiplier: 1.0, constant: 0))
        contentOverlayView!.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .Left, relatedBy: .Equal, toItem: contentOverlayView!, attribute: .Left, multiplier: 1.0, constant: 0))
        contentOverlayView!.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .Right, relatedBy: .Equal, toItem: contentOverlayView!, attribute: .Right, multiplier: 1.0, constant: 0))
        contentOverlayView!.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .Bottom, relatedBy: .Equal, toItem: contentOverlayView!, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }
    
    deinit {
        self.player = nil
       // self.progressBarController.removeFromParentViewController()
        //self.progressBarController.view.removeFromSuperview()
        //self.progressBarController = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setVideos(videos:[Video]) {
        self.videos = videos
        self.currentVideo = videos.first
        var items = [AVPlayerItem]()
        for video in videos {
            if let item = video.getAVPlayerItem() {
                items.append(item)
            }
        }
        self.player = LoopingPlayer(items: items)
        self.player?.play()
        //progressBarController.setLoopingPlayer(player as! LoopingPlayer)
        
    }

    func hidesProgressBar(val:Bool) {
        //self.progressBarController.view.hidden = val
    }
    
    /* Progress Bar Delegate
    ------------------------------------------------------------------------------*/
    
    func playerIsBuffering(isBuffering: Bool) {
        if isBuffering {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func playerError() {
        ErrorHandler.showAlert("Player error")
    }
    
    func didTap() {
//        if let player = self.player as? LoopingPlayer {
//            player.advanceToNextItem()
//        }
    }
    
    func playerDidAdvanceToNextItem() {
        // Move the queue up and put the first element at the end
        let first = videos.first
        for (index, video) in videos.enumerate() {
            if index == 0 {continue}
            videos[index-1] = video
        }
        if first != nil {
            videos[videos.count-1] = first!
        }
        currentVideo = videos.first
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
