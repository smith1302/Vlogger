
import UIKit
import ParseUI

protocol UserTableViewCellDelegate:class {
    func cellFollowed(user:User)
    func cellUnfollowed(user:User)
}

class UserTableViewCell: PFTableViewCell {


    @IBOutlet weak var button: UIButton?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pfImageView: PFImageView!
    
    var following:Bool = false
    var user:User!
    weak var delegate:UserTableViewCellDelegate?
    
    func setButtonRegular() {
        let color = UIColor(white: 0.7, alpha: 1)
        button?.setImage(UIImage(named: "Plus.png"), forState: .Normal)
        button?.tintColor = color
        button?.layer.cornerRadius = button!.frame.size.height/2
        button?.layer.borderWidth = 1
        button?.layer.borderColor = color.CGColor
        button?.backgroundColor = UIColor.whiteColor()
        button?.addTarget(self, action: "followUser", forControlEvents: .TouchUpInside)
    }
    
    func setButtonFollowed() {
        button?.setImage(UIImage(named: "Check"), forState: .Normal)
        button?.tintColor = UIColor.whiteColor()
        button?.layer.cornerRadius = button!.frame.size.height/2
        button?.layer.borderWidth = 0
        button?.backgroundColor = Constants.primaryColor
        button?.addTarget(self, action: "unfollowUser", forControlEvents: .TouchUpInside)
    }
    
    func configure(user:User) {
        setFollow(false, enabled: false)
        self.user = user
        
        // Namelabel
        nameLabel.text = user.username
        nameLabel.textColor = Constants.usernameTextPrimaryColor
        nameLabel.backgroundColor = UIColor.clearColor()
        
        pfImageView.file = user.picture
        pfImageView.image = UIImage(named: "Avatar.png")
        pfImageView.loadInBackground()
        pfImageView.layer.cornerRadius = pfImageView.frame.size.height/2
        pfImageView.layer.masksToBounds = true
        pfImageView.backgroundColor = UIColor.lightGrayColor()
        pfImageView.layer.borderWidth = 1
        pfImageView.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
        
        if user.isUs() {
            button?.enabled = false
            setFollow(false, enabled: false)
        }
    }
    
    func setFollow(isFollowing:Bool, enabled:Bool) {
        self.following = isFollowing
        if following {
            setButtonFollowed()
        } else {
            setButtonRegular()
        }
    }
    
    func followUser() {
        delegate?.cellFollowed(user)
        setFollow(true, enabled: true)
    }
    
    func unfollowUser() {
        delegate?.cellUnfollowed(user)
        setFollow(false, enabled: true)
    }
    
    override func drawRect(rect: CGRect) {
        pfImageView.layer.cornerRadius = pfImageView.frame.size.height/2
    }
}
