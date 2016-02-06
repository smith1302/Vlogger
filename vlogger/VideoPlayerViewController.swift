//
//  VideoPlayerViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/5/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import AVFoundation
import Parse
import AVKit

protocol VideoPlayerViewControllerDelegate: class {
    func currentVideoChanged(_:Video?)
}

class VideoPlayerViewController: AVPlayerViewController, VideoProgressBarDelegate {
    
    var sessionQueue = dispatch_queue_create("videoPlayerControllerQueue", DISPATCH_QUEUE_SERIAL)
    var progressBarController:VideoProgressBarViewController!
    var activityIndicator:ActivityIndicatorView!
    var videos:[Video] = [Video]()
    var currentBufferState:Bool = true
    var cover:UIView!
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
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
    
    init(story:Story) {
        super.init(nibName: nil, bundle: nil)
        commonInit()
        let query = story.videos.query()
        query.findObjectsInBackgroundWithBlock({
            (objects:[PFObject]?, error:NSError?) in
            if let videos = objects as? [Video] {
                self.setVideos(videos)
            }
        })
    }
    
    func commonInit() {
        videoGravity = AVLayerVideoGravityResizeAspectFill
        showsPlaybackControls = false
        
        self.progressBarController = VideoProgressBarViewController()
        self.progressBarController.delegate = self
        self.addChildViewController(progressBarController)
        
        dispatch_async(sessionQueue, {
            let progressBarControllerView = self.progressBarController.view
            dispatch_async(dispatch_get_main_queue(), {
                [weak self] in
                if let weakself = self {
                    weakself.view.addSubview(progressBarControllerView)
                }
            })
        })
        
        // Cover (so we can fade the video in).
        cover = UIView(frame: view.bounds)
        cover.backgroundColor = UIColor.blackColor()
        //view.addSubview(cover)
        //Utilities.autolayoutSubviewToViewEdges(cover, view: view)
        
        // Activity Indicator View
        activityIndicator = ActivityIndicatorView(frame: view.bounds)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        Utilities.autolayoutSubviewToViewEdges(activityIndicator, view: view)
        view.bringSubviewToFront(activityIndicator)
        
        addObserver(self, forKeyPath: "readyForDisplay", options: .New, context: nil)
    }
    
    func configureWithStory(story:Story) {
        story.getVideos({
            (videos:[Video]) in
            self.setVideos(videos)
        })
    }
    
    deinit {
        removeObserver(self, forKeyPath: "readyForDisplay", context: nil)
        self.pause()
        (self.player as? LoopingPlayer)?.cleanUp()
        self.player = nil
        self.progressBarController.removeFromParentViewController()
        self.progressBarController.view.removeFromSuperview()
        self.progressBarController = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.pause()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
        super.viewWillAppear(animated)
        self.play()
        self.cover.alpha = 1
        self.view.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateWithDuration(0.4, delay: 0.2, options: .CurveLinear, animations: {
            self.view.alpha = 1
            }, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func applicationDidEnterBackground() {
        self.pause()
    }
    
    func applicationWillEnterForeground() {
        self.play()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "readyForDisplay" {
            if view.alpha == 1 {
                UIView.animateWithDuration(0.25, delay: 0, options: .CurveLinear, animations: {
                    self.cover.alpha = 0
                }, completion: nil)
            }
            if currentBufferState == false {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    private func setVideos(videos:[Video]) {
        if videos.count == 0 {
            activityIndicator.stopAnimating()
            myDelegate?.currentVideoChanged(nil)
            return
        }
        self.videos = videos
        self.currentVideo = videos.first
        var items = [AVPlayerItem]()
        var i = 0
        var addedVideoIds = [String:Bool]() // To keep track incase there are dupes
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            for video in videos {
                // Make sure we havent already added this video
                if let objectId = video.objectId, _ = addedVideoIds[objectId] {
                    continue
                }
                if let item = video.getAVPlayerItem() {
                    if let objectId = video.objectId {
                        addedVideoIds[objectId] = true
                    }
                    items.append(item)
                    video.tag = i++
                }
            }
            let loopingPlayer = LoopingPlayer(items: items)
            self.player = loopingPlayer
            dispatch_async(dispatch_get_main_queue()){
                [weak self] in
                if let weakSelf = self {
                    weakSelf.progressBarController.setLoopingPlayer(loopingPlayer)
                }
            }
        }
        
    }
    
    func removeCurrentVideo() {
        videos = Array(videos.dropFirst())
        currentVideo = videos.first
        if let player = player as? LoopingPlayer {
            player.removeCurrentItem()
            progressBarController.setLoopingPlayer(player)
        }
    }

    func hidesProgressBar(val:Bool) {
        self.progressBarController.view.hidden = val
    }
    
    /* Progress Bar Delegate
    ------------------------------------------------------------------------------*/
    
    func playerCurrentItemReady() {
    }
    
    func playerIsBuffering(isBuffering: Bool) {
        currentBufferState = isBuffering
        if isBuffering {
            activityIndicator.startAnimating()
        } else if !isBuffering && readyForDisplay {
            activityIndicator.stopAnimating()
        }
    }
    
    func playerError() {
        ErrorHandler.showAlert("Player error")
        activityIndicator.stopAnimating()
    }
    
    func playerDidAdvanceToNextItem() {
        // Cycle the order of the videos queue
        // Move the queue up and put the first element at the end
        let first = videos.first
        videos = Array(videos.dropFirst())
        if first != nil {
            videos.append(first!)
        }
        currentVideo = videos.first
    }
    
    func pause() {
        player?.pause()
    }
    
    func play() {
        player?.play()
    }
    
    func playerHasNoVideosToPlay() {
        myDelegate?.currentVideoChanged(nil)
    }
    
    /* Actions
    ------------------------------------------------------------------------------*/
    
    func didTap() {
        if let player = self.player as? LoopingPlayer {
            player.advanceToNextItem()
        }
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
