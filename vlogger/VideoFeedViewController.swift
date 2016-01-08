//
//  VideoFeedViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/6/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class VideoFeedViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var customOverlayView: UIView!
    @IBOutlet weak var nameButton: UIButtonOutline!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var xButton: UIButton!
    
    // Other
    var videoPlayerViewController:VideoPlayerViewController!
    var videos:[Video] = [Video]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled = true
        
        videoPlayerViewController = VideoPlayerViewController(frame: view.frame)
        addChildViewController(videoPlayerViewController)
        view.addSubview(videoPlayerViewController.view)
        view.bringSubviewToFront(customOverlayView)
        customOverlayView.userInteractionEnabled=true
        
        let user = User.currentUser()!
        user.getVideos({
            (videos:[Video]) in
            self.videos = videos
            self.displayVideos()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayVideos() {
        videoPlayerViewController.setVideos(videos)

        videoPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: videoPlayerViewController.view, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: videoPlayerViewController.view, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: videoPlayerViewController.view, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: videoPlayerViewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }
    
    /* IBActions
    ------------------------------------------------------------------*/
    @IBAction func xButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        videoPlayerViewController.didTap()
    }
}
