//
//  VideoFeedViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/6/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import AVFoundation

class VideoFeedViewController: UIViewController, VideoPlayerViewControllerDelegate, LikeButtonDelegate, OptionalButtonDelegate, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var customOverlayView: UIView!
    @IBOutlet weak var nameButton: UIButtonOutline!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var viewCountLabel: UILableOutline!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILableOutline!
    @IBOutlet weak var noStoriesFoundView: UIView!
    @IBOutlet weak var optionalButton: OptionalButton!
    @IBOutlet weak var titleTextField: UITextFieldOutline?
    
    // Other
    var uploadFailedOverlay:UploadFailedVideoView?
    var videoPlayerViewController:VideoPlayerViewController!
    var currentVideo:Video?
    var user:User? {
        didSet {
            if let user = self.user {
                titleTextField?.userInteractionEnabled = user.isUs()
            } else {
                titleTextField?.userInteractionEnabled = false
            }
        }
    }
    var story:Story!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.videoPlayerViewController = VideoPlayerViewController()
        self.videoPlayerViewController.myDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled = true
        
        likeButton.delegate = self
        likeCountLabel.textAlignment = .Right
        noStoriesFoundView.alpha = 0
        
        // Configure video player
        self.videoPlayerViewController.view.frame = self.view.frame
        self.addChildViewController(self.videoPlayerViewController)
        self.view.addSubview(self.videoPlayerViewController.view)
        self.view.bringSubviewToFront(self.customOverlayView)
        
        // Optional Button
        optionalButton.delegate = self
        
        // Textfield
        titleTextField?.delegate = self
        titleTextField?.textAlignment = .Left
        titleTextField?.text = ""
        
        // Username
        if user == nil {
            optionalButton.hidden = true
            nameButton.enabled = false
        }
    }
    
    func viewIsConfigured() {
        // Username
        nameButton.enabled = true
        nameButton.setTitle(user!.username!, forState: .Normal)
        // Title
        titleTextField?.userInteractionEnabled = self.user!.isUs()
        titleTextField?.text = story.title
        // Optional button
        optionalButton.configure(user!, story: story)
        // Video Player controller
        self.videoPlayerViewController.configureWithStory(story)
    }
    
    func setUpIfPossible() {
        if user == nil || story == nil {
            return
        }
        viewIsConfigured()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Utilities.autolayoutSubviewToViewEdges(self.videoPlayerViewController.view, view: self.view)
        // Autolayout doesnt configure the constraints until AFTER the view appears. So hide them now and unhide them in viewdidappear...
        customOverlayView.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.3, delay: 0.25, options: .CurveLinear, animations: {
                self.customOverlayView.alpha = 1
            }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureWithUser(user:User) {
        self.user = user
        setUpIfPossible()
    }
    
    func configureStory(story:Story) {
        self.story = story
        setUpIfPossible()
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
        videoPlayerViewController?.activityIndicator.stopAnimating()
        noStoriesFoundView.alpha = 1
        Utilities.springAnimation(noStoriesFoundView, completion: {})
    }
    
    /* Like Button Delegate
    ------------------------------------------------------------------*/
    
    func didLikeVideo() {
        self.showHeart()
        likeCountLabel.text = "\(currentVideo!.likes.pretty())"
    }
    
    func didUnlikeVideo() {
        likeCountLabel.text = "\(currentVideo!.likes.pretty())"
    }
    
    /* Delete Button Delegate
    ------------------------------------------------------------------*/
    
    func didCancelDelete() {
        videoPlayerViewController.play()
    }
    
    func didConfirmDeleteSnap() {
        story?.removeVideo(currentVideo)
        videoPlayerViewController.removeCurrentVideo()
        videoPlayerViewController.play()
    }
    
    func didConfirmDeleteStory() {
        story?.deleteEventually()
        videoPlayerViewController.removeCurrentVideo()
        videoPlayerViewController.play()
    }
    
    func didTapDelete() {
        videoPlayerViewController.pause()
    }
    
    func flagVideo() {
        currentVideo?.flag()
    }
    
    /* Actions
    ------------------------------------------------------------------*/
    @IBAction func xButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesBegan(touches, withEvent: event)
//        if let ttf = titleTextField where ttf.isFirstResponder() {
//            titleTextField?.resignFirstResponder()
//        } else if uploadFailedOverlay == nil {
//            videoPlayerViewController.didTap()
//        } else {
//            retryUpload()
//        }
//    }
    
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
    
    /* Title Text Field
    ------------------------------------------------------*/
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if let story = story, newText = textField.text where newText != story.title && !newText.isEmpty {
            story.title = newText
            story.tags = story.getTagsFromString(newText)
            story.saveEventually()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldString = textField.text ?? ""
        let startIndex = oldString.startIndex.advancedBy(range.location)
        let endIndex = startIndex.advancedBy(range.length)
        let newString = oldString.stringByReplacingCharactersInRange(startIndex ..< endIndex, withString: string)
        return newString.characters.count <= 40
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
        viewCountLabel.text = currentVideo != nil ? currentVideo!.views.pretty() : "\(0)"
        likeButton.configure(currentVideo)
        likeCountLabel.text = currentVideo != nil ? currentVideo!.likes.pretty() : "\(0)"
        if currentVideo == nil {
            optionalButton.hide()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ProfileViewController, user = self.user {
            vc.configure(user)
        }
    }
    
    func pause() {
        videoPlayerViewController.pause()
    }
    
    func play() {
        videoPlayerViewController.play()
    }
}
