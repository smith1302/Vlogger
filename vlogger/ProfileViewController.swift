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
    
    @IBOutlet weak var imageView: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var storiesLabel: UILabel!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var subscribersButton: UIButton!
    @IBOutlet weak var followButton: FollowButton!
    @IBOutlet weak var headerBackground: UIView!
    @IBOutlet weak var storyboardTableView: UITableView!
    
    var user:User?
    var profileTableViewController:ProfileTableViewController!
    let imagePicker = UIImagePickerController()
    
    func configure(user:User) {
        self.user = user
    }
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false;
        imagePicker.delegate = self
        super.viewDidLoad()
        
        profileTableViewController = ProfileTableViewController(user: user!, tableView: storyboardTableView)
        addChildViewController(profileTableViewController)
        profileTableViewController.loadObjects()
        
        headerBackground.backgroundColor = Constants.primaryColor
        usernameLabel.textColor = UIColor.whiteColor()
        
        usernameLabel.text = user!.username!
        viewsLabel.text = "0"
        storiesLabel.text = "0"
        subscribersLabel.text = "0"
        
        subscribersLabel.alpha = 0.6
        user!.getTotalSubscribers({
            (count:Int) in
            self.subscribersLabel.alpha = 1
            self.subscribersLabel.text = "\(count)"
        })
        
        viewsLabel.alpha = 0.6
        user!.getTotalViews({
            (count:Int) in
            self.viewsLabel.alpha = 1
            self.viewsLabel.text = "\(count)"
        })
        
        followButton.configure(user!)
        
        // Round imageview
        imageView.layer.cornerRadius = imageView.frame.size.height/2
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor(white: 1, alpha: 1).CGColor
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "Avatar.png")
        imageView.file = user!.picture
        imageView.loadInBackground()
        
        // Subscribe button
        followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        followButton.layer.cornerRadius = 5
        followButton.layer.borderWidth = 2
        followButton.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func showFollowers(sender: AnyObject) {
        let storyboard = self.storyboard
        if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("FollowingViewController") as? FollowingViewController {
            destinationVC.configure(user!)
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    @IBAction func followButtonClicked(sender: AnyObject) {
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
        if user!.objectId != User.currentUser()!.objectId {
            return
        }
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.contentMode = .ScaleAspectFill
        imageView.image = image
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
