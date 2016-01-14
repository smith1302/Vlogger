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

class VideoFeedViewController: UIViewController, VideoPlayerViewControllerDelegate, LikeButtonDelegate, OptionalButtonDelegate {
    
    // Outlets
    @IBOutlet weak var customOverlayView: UIView!
    @IBOutlet weak var nameButton: UIButtonOutline!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var viewCountLabel: UILableOutline!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILableOutline!
    @IBOutlet weak var updateLabel: UILableOutline! // "No recent updates"
    @IBOutlet weak var optionalButton: OptionalButton!
    
    // Other
    var uploadFailedOverlay:UploadFailedVideoView?
    var videoPlayerViewController:VideoPlayerViewController!
    var currentVideo:Video?
    var user:User!
    weak var delegate:VideoFeedViewControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled = true
        view.backgroundColor = UIColor.redColor()
        
        likeButton.delegate = self
        likeCountLabel.textAlignment = .Right
        updateLabel.hidden = true
        
        // Configure name button title
        nameButton.setTitle(user.username!, forState: .Normal)
        // Configure video player
        videoPlayerViewController = VideoPlayerViewController(user: user)
        videoPlayerViewController.myDelegate = self
        videoPlayerViewController.view.frame = view.frame
        addChildViewController(videoPlayerViewController)
        view.addSubview(videoPlayerViewController.view)
        view.bringSubviewToFront(customOverlayView)
        Utilities.autolayoutSubviewToViewEdges(videoPlayerViewController.view, view: view)
        
        // Optional Button
        optionalButton.delegate = self
        optionalButton.configure(user)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(user:User) {
        self.user = user
        // Views aren't ready yet so we must configure them in viewDidLoad
    }
    
    /* VideoPlayerViewController Delegate
    ------------------------------------------------------------------*/
    
    // Only way this calls when there are no videos left is through noVideosFound()
    func currentVideoChanged(video: Video?) {
        if video == nil {
            noVideosFound()
        }
        
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
    
    func noVideosFound() {
        self.updateLabel.textAlignment = .Center
        UIView.animateWithDuration(0.4, animations: {
            self.updateLabel.hidden = false
        })
    }
    
    /* Like Button Delegate
    ------------------------------------------------------------------*/
    
    func didLikeVideo() {
        self.showHeart()
        likeCountLabel.text = "\(currentVideo!.likes)"
    }
    
    func didUnlikeVideo() {
        likeCountLabel.text = "\(currentVideo!.likes)"
    }
    
    /* Like Button Delegate
    ------------------------------------------------------------------*/
    
    func didCancelDelete() {
        videoPlayerViewController.play()
    }
    
    func didConfirmDelete() {
        currentVideo?.deleteEventually() // Also removes temporary video cache
        videoPlayerViewController.removeCurrentVideo()
        videoPlayerViewController.play()
    }
    
    func didTapDelete() {
        videoPlayerViewController.pause()
    }
    
    func flagVideo() {
        currentVideo?.flag()
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
    
    @IBAction func usernameClicked(sender: AnyObject) {
        delegate?.showProfileCard()
    }
    
    /* Visual Effects
    ------------------------------------------------------------------*/
    
    func showHeart() {
        let image = UIImage(named: "Like-Empty.png")
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = UIColor.clearColor()
        imageView.contentMode = .Center
        imageView.frame = view.bounds
        imageView.alpha = 1
        view.addSubview(imageView)
        imageView.transform = CGAffineTransformMakeScale(0.01, 0.01)
        UIView.animateWithDuration(1,delay: 0.2,usingSpringWithDamping: 0.55,initialSpringVelocity: 0.9, options: .CurveEaseInOut,
            animations: {
                imageView.transform = CGAffineTransformMakeScale(1, 1)
                imageView.alpha = 1
            },
            completion: {
                finished in
                UIView.animateWithDuration(0.2, delay: 0.8, options: .CurveEaseIn,
                    animations: {
                        imageView.transform = CGAffineTransformMakeScale(0.01, 0.01)
                        imageView.alpha = 0
                    }, completion: {
                        finished in
                        imageView.removeFromSuperview()
                })
        })
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
    
    // Typically called on video changed
    func updateViews() {
        currentVideo?.setViewed()
        viewCountLabel.text = "\(currentVideo?.views ?? 0)"
        likeButton.configure(currentVideo)
        likeCountLabel.text = "\(currentVideo?.likes ?? 0)"
        
        if currentVideo == nil {
            optionalButton.hide()
        }
    }
}
