//
//  VideoViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/4/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import AVFoundation
import Parse
import Firebase

class VideoViewController: AVFoundationViewController, RecordButtonDelegate, VideoSaveOverlayDelegate {
    
    @IBOutlet weak var recordButton: RecordButton!
    
    var videoSaveOverlayView:VideoSaveOverlayView?
    var activityIndicator:ActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Record button
        recordButton.delegate = self
        // Activity Indicator
        activityIndicator = ActivityIndicatorView(frame: view.frame)
        view.addSubview(activityIndicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Swipe to transition setup
        if let ncd = self.navigationController?.delegate as? NavigationControllerDelegate {
            ncd.addSwipableController(self)
            ncd.addDirectionSegue(swipeLeft: "toProfileViewController", swipeRight: "toHomeViewController")
        }
    }
    
    /* Record Button Delegate
    ------------------------------------------*/
    func recordFinished() {
        activityIndicator.startAnimating()
        super.recordingStop()
    }
    
    func recordStarted() {
        Utilities.setAudioSessionCategory(AVAudioSessionCategoryPlayAndRecord)
        super.recordingStart()
    }
    
    /* Video Save Overlay Delegate
    ------------------------------------------*/
    func cancelPressed() {
        cleanupCurrentVideo()
    }
    
    func continuePressed() {
        removeVideoPlayerPreview()
        MessageHandler.showMessage("Video will be added shortly")
    }
    
    func addVideoToNewStoryPressed() {
        User.currentUser()!.uploadVideoToNewStory(currentVideo, failureCallback: {
                self.cleanupCurrentVideo()
            }, successCallback: {
                self.cleanupCurrentVideo()
        })
        continuePressed()
    }
    
    func addVideoToCurrentStoryPressed() {
        User.currentUser()!.uploadVideoToCurrentStory(currentVideo, failureCallback: {
                self.cleanupCurrentVideo()
            }, successCallback: {
                self.cleanupCurrentVideo()
        })
        continuePressed()
    }
    
    /* AVFoundation View Controller
    ------------------------------------------*/
    
    // When we get the video output playback lets show the video overlay
    override func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError?) {
        activityIndicator.stopAnimating()
        super.captureOutput(captureOutput, didFinishRecordingToOutputFileAtURL: outputFileURL, fromConnections: connections, error: error)
        if error == nil {
            addVideoSaveOverlay()
        }
    }
    
    /* IBActions
    ------------------------------------------*/
    
    @IBAction func switchCameraPressed(sender: AnyObject) {
        flipCameraPosition()
    }
    
    /* Other
    ------------------------------------------*/
    
    func addVideoSaveOverlay() {
        videoSaveOverlayView = VideoSaveOverlayView(frame: CGRectMake(0,0,view.frame.size.width,view.frame.size.height))
        videoSaveOverlayView!.delegate = self
        addChildViewController(videoSaveOverlayView!)
        view.addSubview(videoSaveOverlayView!.view)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationVC = segue.destinationViewController as? ProfileViewController {
            destinationVC.configure(User.currentUser()!)
        }
    }
    
    @IBAction func unwindToVideoViewController(segue: UIStoryboardSegue) {
    }
    
}
