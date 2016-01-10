//
//  ProfileCardViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/9/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

protocol ProfileCardViewControllerDelegate:class {
    func profileCardClosed()
}

class ProfileCardViewController: UIViewController {
    
    @IBOutlet weak var imageView: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followButton: FollowButton!
    @IBOutlet weak var profileView: ProfileCardView!
    @IBOutlet weak var top: UIView!
    @IBOutlet weak var lineSeperator: UIView!
    weak var delegate:ProfileCardViewControllerDelegate?
    
    var user:User?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        customInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    func customInit() {
        
    }
    
    func configure(user:User) {
        self.user = user
        imageView.file = user.picture
        imageView.loadInBackground()
        
        viewsLabel.text = "0"
        rankLabel.text = "0"
        followersButton.setTitle("0", forState: .Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        top.backgroundColor = Constants.primaryColor
        lineSeperator.backgroundColor = Constants.darkPrimaryColor
        
        profileView.userInteractionEnabled = true
        profileView.transform = CGAffineTransformMakeScale(0.01, 0.01)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Display with a spring
        UIView.animateWithDuration(1,
            delay: 0.2,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 0.8,
            options: .CurveEaseInOut,
            animations: {
                self.profileView.transform = CGAffineTransformMakeScale(1, 1)
                self.view.alpha = 1
            },
            completion: nil)
        
        // Round imageview
        imageView.layer.cornerRadius = imageView.frame.size.height/2
        imageView.layer.borderWidth = 6
        imageView.layer.borderColor = top.backgroundColor?.CGColor
        imageView.layer.masksToBounds = true
        
        // Round edges of view
        roundCorner(top, corners: [.TopLeft, .TopRight])
        roundCorner(followButton, corners: [.BottomLeft, .BottomRight])
    }
    
    func roundCorner(view:UIView, corners:UIRectCorner) {
        // Top rounded corners
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSizeMake(10, 10))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.CGPath
        view.layer.mask = maskLayer
    }
    
    @IBAction func showFollowers(sender: AnyObject) {
        let storyboard = self.storyboard
        if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("FollowingViewController") as? FollowingViewController, parentVC = parentViewController {
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }

    @IBAction func followButtonClicked(sender: AnyObject) {
        user?.followUser()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let view = touches.first?.view where view != self.view {
            return
        }
        UIView.animateWithDuration(0.2,
            animations: {
                self.profileView.transform = CGAffineTransformMakeScale(0.01, 0.01)
                self.profileView.alpha = 0
                self.view.alpha = 0
            },
            completion: {
                finished in
                self.delegate?.profileCardClosed()
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
