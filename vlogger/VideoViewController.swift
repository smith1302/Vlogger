//
//  VideoViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/4/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: AVFoundationViewController, RecordButtonDelegate, VideoSaveOverlayDelegate {
    
    var recordButton:RecordButton!
    
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
    
    func addVideoSaveOverlay() {
        let height:CGFloat = 70
        let overlayView = VideoSaveOverlayView(frame: CGRectMake(0,view.frame.size.height-height,view.frame.size.width,height))
        overlayView.delegate = self
        view.addSubview(overlayView)
    }
}
