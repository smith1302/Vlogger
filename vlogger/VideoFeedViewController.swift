//
//  VideoFeedViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/6/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoFeedViewControllerDelegate:class {
    func showProfileCard()
}

class VideoFeedViewController: UIViewController, VideoPlayerViewControllerDelegate {
    
    // Outlets
    @IBOutlet weak var customOverlayView: UIView!
    @IBOutlet weak var nameButton: UIButtonOutline!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var xButton: UIButton!
    
    // Other
    var uploadFailedOverlay:UploadFailedVideoView?
    var videoPlayerViewController:VideoPlayerViewController!
    var videos:[Video] = [Video]()
    var currentVideo:Video?
    weak var delegate:VideoFeedViewControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled = true
        view.backgroundColor = UIColor.redColor()
        
        videoPlayerViewController = VideoPlayerViewController(user: User.currentUser()!)
        videoPlayerViewController.myDelegate = self
        videoPlayerViewController.view.frame = view.frame
        addChildViewController(videoPlayerViewController)
        view.addSubview(videoPlayerViewController.view)
        view.bringSubviewToFront(customOverlayView)
        
        Utilities.autolayoutSubviewToViewEdges(videoPlayerViewController.view, view: view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /* VideoPlayerViewController Delegate
    ------------------------------------------------------------------*/
    
    func currentVideoChanged(video: Video?) {
        self.currentVideo = video
        uploadFailedOverlay?.removeFromSuperview()
        uploadFailedOverlay = nil
        if let video = video where (video.uploadFailedFlag || video.uploadInProgressFlag) {
            uploadFailedOverlay = UploadFailedVideoView(frame: view.frame)
            view?.addSubview(uploadFailedOverlay!)
            if video.uploadFailedFlag {
                uploadFailedOverlay?.showFailedMessage()
            } else if video.uploadInProgressFlag {
                uploadFailedOverlay?.showLoader()
            }
            Utilities.autolayoutSubviewToViewEdges(uploadFailedOverlay!, view: view)
            view?.bringSubviewToFront(customOverlayView)
        }
        updateViews()
    }
    
    /* IBActions
    ------------------------------------------------------------------*/
    @IBAction func xButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if uploadFailedOverlay == nil {
            videoPlayerViewController.didTap()
        } else {
            retryUpload()
        }
    }
    
    @IBAction func likeButtonClicked(sender: AnyObject) {
        
    }
    
    
    @IBAction func usernameClicked(sender: AnyObject) {
        delegate?.showProfileCard()
    }
    
    
    /* Helpers
    ------------------------------------------------------------------*/
    
    func retryUpload() {
        uploadFailedOverlay?.showLoader()
        if let video = currentVideo where (video.uploadFailedFlag && !video.uploadInProgressFlag) {
            video.uploadVideo({
                    self.uploadFailedOverlay?.showFailedMessage()
                }, successCallback: {
                    self.uploadFailedOverlay?.removeFromSuperview()
                    self.uploadFailedOverlay = nil
            })
        }
    }
    
    func updateViews() {
        if currentVideo == nil { return }
        currentVideo?.setViewed()
        viewCountLabel.text = "\(currentVideo!.views)"
    }
}
