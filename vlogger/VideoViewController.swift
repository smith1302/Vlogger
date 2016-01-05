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
    
    var recordButton:RecordButton!
    var videoSaveOverlayView:VideoSaveOverlayView?
    let activityIndicator:ActivityIndicatorView = ActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Record button
        let radius:CGFloat = 43
        var point = view.center
        point.y = view.frame.size.height-radius-25
        recordButton = RecordButton(center: point, radius: radius)
        recordButton.delegate = self
        view.addSubview(recordButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Record Button Delegate
    ------------------------------------------*/
    func recordFinished() {
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
        
    }
    
    
    /* AVFoundation View Controller
    ------------------------------------------*/
    
    // When we get the video output playback lets show the video overlay
    override func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        super.captureOutput(captureOutput, didFinishRecordingToOutputFileAtURL: outputFileURL, fromConnections: connections, error: error)
        addVideoSaveOverlay()
    }
    
    /* IBActions
    ------------------------------------------*/
    
    @IBAction func switchCameraPressed(sender: AnyObject) {
        flipCameraPosition()
    }
    
    /* Other
    ------------------------------------------*/
    
    var fileUploadBackgroundTaskID:UIBackgroundTaskIdentifier?
    var photoPostBackgroundTaskID:UIBackgroundTaskIdentifier?
    
    func uploadImage(image:UIImage) {
        
        activityIndicator.startAnimating()
        videoSaveOverlayView?.remove()
        
        if currentVideoFileURL?.path == nil {
            self.uploadFailed()
            return
        }
        
        let videoData = NSData(contentsOfFile: currentVideoFileURL!.path!)
        if videoData == nil {
            self.uploadFailed()
            return
        }
        
        if let file = PFFile(data: videoData!) {
            // Create a background thread to continue the operation if the user backgrounds the app
            fileUploadBackgroundTaskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
                UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskID!)
            })
            // Save the photo
            file.saveInBackgroundWithBlock {
                (success:Bool, error:NSError?) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskID!)
                if error != nil {
                    self.uploadFailed()
                    ErrorHandler.showAlert(error?.description)
                }
            }
            // Attach the photo to a PFObject
            let video = Video(file: file)
            
            // Make another background thread for uploading the PFObject
            photoPostBackgroundTaskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
                UIApplication.sharedApplication().endBackgroundTask(self.photoPostBackgroundTaskID!)
            })
            
            // Upload the PFObject
            video.saveInBackgroundWithBlock({
                (success:Bool, error:NSError?) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoPostBackgroundTaskID!)
                self.uploadFinished()
                if error != nil {
                    ErrorHandler.showAlert(error?.description)
                    self.uploadFailed()
                } else if success {
                    MessageHandler.showMessage(kPhotoUploadSuccess)
                    self.uploadSucceeded()
                }
            })
        } else {
            uploadFailed()
        }
    }
    
    func uploadFailed() {
        uploadFinished()
    }
    
    func uploadSucceeded() {
        uploadFinished()
    }
    
    func uploadFinished() {
        activityIndicator.stopAnimating()
    }
    
    func addVideoSaveOverlay() {
        let height:CGFloat = 70
        videoSaveOverlayView = VideoSaveOverlayView(frame: CGRectMake(0,view.frame.size.height-height,view.frame.size.width,height))
        videoSaveOverlayView!.delegate = self
        view.addSubview(videoSaveOverlayView!)
    }
}
