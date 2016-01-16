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
        navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarHidden = true
        super.viewWillAppear(animated)
    }
    
    /* Record Button Delegate
    ------------------------------------------*/
    func recordFinished() {
        activityIndicator.startAnimating()
        super.recordingStop()
        
    }
    
    func recordStarted() {
        super.recordingStart()
    }
    
    /* Video Save Overlay Delegate
    ------------------------------------------*/
    func cancelPressed() {
        cleanupCurrentVideo()
    }
    
    func continuePressed() {
        uploadImage()
        removeVideoPlayerPreview()
        MessageHandler.showMessage("Video will be uploaded shortly")
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
    
    func uploadImage() {
        videoSaveOverlayView?.remove()
        currentVideo?.uploadVideo({
            }, successCallback: {
        })
    }
    
    func addVideoSaveOverlay() {
        let height:CGFloat = 70
        videoSaveOverlayView = VideoSaveOverlayView(frame: CGRectMake(0,view.frame.size.height-height,view.frame.size.width,height))
        videoSaveOverlayView!.delegate = self
        view.addSubview(videoSaveOverlayView!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationVC = segue.destinationViewController as? FeedViewController {
            destinationVC.configureWithUser(User.currentUser()!)
        }
    }
}
