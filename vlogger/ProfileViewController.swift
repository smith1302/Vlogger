//
//  ProfileViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var imageView: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var storiesLabel: UILabel!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var subscribersButton: UIButton!
    @IBOutlet weak var followButton: FollowButton!
    @IBOutlet weak var headerBackground: UIView!
    @IBOutlet weak var storyboardTableView: UITableView!
    var bgImageView:UIImageView?
    
    var user:User?
    var profileTableViewController:ProfileTableViewController!
    let imagePicker = UIImagePickerController()
    
    func configure(user:User) {
        self.user = user
        if user.isUs() {
            user.fetchInBackground()
        }
    }
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false;
        imagePicker.delegate = self
        super.viewDidLoad()
        
        headerBackground.backgroundColor = UIColor.whiteColor()
        usernameLabel.textColor = UIColor.whiteColor()
        
        // Settings
        if !user!.isUs() {
            settingsButton.hidden = true
        }
        
        usernameLabel.text = user!.username!
        viewsLabel.text = "0"
        storiesLabel.text = "0"
        subscribersLabel.text = "0"
        
        self.subscribersLabel.text = "\(user!.subscriberCount)"
        
        viewsLabel.alpha = 0.2
        user!.getTotalViews({
            (count:Int) in
            self.viewsLabel.alpha = 1
            self.viewsLabel.text = "\(count)"
        })
        
        storiesLabel.alpha = 0.2
        user!.getStoryCount({
            (count:Int) in
            self.storiesLabel.alpha = 1
            self.storiesLabel.text = "\(count)"
        })
        
        followButton.configure(user!)
        
        setBlurredBackground(UIImage(named: "background.jpg"))
        // Round imageview
        imageView.hidden = true
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor(white: 1, alpha: 1).CGColor
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "Avatar.png")
        imageView.file = user!.picture
        imageView.layer.cornerRadius = imageView.frame.size.height/2
        
        // Subscribe button
        followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        followButton.layer.cornerRadius = 5
        followButton.layer.borderWidth = 2
        followButton.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        
        // Profile table view controller
        profileTableViewController = ProfileTableViewController(user: user!, tableView: storyboardTableView)
        addChildViewController(profileTableViewController)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        imageView.hidden = true
        UIApplication.sharedApplication().statusBarHidden = true
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        profileTableViewController.loadObjects()
        imageView.loadInBackground({
            (image:UIImage?, error:NSError?) in
            self.imageView.hidden = false
            self.setBlurredBackground(image)
            self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2
            Utilities.springAnimation(self.imageView, completion: nil)
        })
    }
    
    func setBlurredBackground(image:UIImage?) {
        if image == nil { return }
        if bgImageView == nil {
            bgImageView = UIImageView(image: image)
            bgImageView!.frame = self.headerBackground.bounds
            let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Light)
            let blurView = UIVisualEffectView(effect: darkBlur)
            blurView.frame = bgImageView!.bounds
            bgImageView!.addSubview(blurView)
            self.headerBackground.addSubview(bgImageView!)
            self.headerBackground.sendSubviewToBack(bgImageView!)
        } else {
            bgImageView?.image = image
        }
    }
    
    /*  Actions
    --------------------------------------------------------*/
    
    
    @IBAction func goBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func showFollowers(sender: AnyObject) {
        let storyboard = self.storyboard
        if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("FollowingViewController") as? FollowingViewController {
            destinationVC.configure(user!)
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    @IBAction func followButtonClicked(sender: AnyObject) {
        if user!.isUs() {
            return
        }
        
        if followButton.following {
            user?.unfollowUser()
            // Now that we are unfollowing them, show "Follow"
            followButton.setFollow()
        } else {
            user?.followUser()
            followButton.setUnfollow()
        }
    }
    
    /*  Image Picker
    --------------------------------------------------------*/
    
    @IBAction func profilePictureTapped(sender: AnyObject) {
        if !user!.isUs() {
            return
        }
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.contentMode = .ScaleAspectFill
        imageView.image = image
        setBlurredBackground(image)
        if let imageData = UIImageJPEGRepresentation(image, 0.6) {
            let file = PFFile(data: imageData)
            User.currentUser()?.changeProfilePicture(file!)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
