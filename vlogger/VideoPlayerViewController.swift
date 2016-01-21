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
    
    var progressBarController:VideoProgressBarViewController!
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
    
    init(user:User) {
        super.init(nibName: nil, bundle: nil)
        commonInit()
        user.getCurrentStoryVideos({
            (videos:[Video]) in
            self.setVideos(videos)
        })
    }
    
    func commonInit() {
        videoGravity = AVLayerVideoGravityResizeAspectFill
        showsPlaybackControls = false
        
        self.progressBarController = VideoProgressBarViewController()
        self.progressBarController.delegate = self
        self.addChildViewController(progressBarController)
        view.addSubview(progressBarController.view)
        
        // Activity Indicator View
        activityIndicator = ActivityIndicatorView(frame: view.bounds)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        Utilities.autolayoutSubviewToViewEdges(activityIndicator, view: view)
    }
    
    func configureWithStory(story:Story) {
        story.getVideos({
            (videos:[Video]) in
            self.setVideos(videos)
        })
    }
    
    deinit {
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
        self.play()
        super.viewWillAppear(animated)
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
        self.player = LoopingPlayer(items: items)
        progressBarController.setLoopingPlayer(self.player as! LoopingPlayer)
        
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
