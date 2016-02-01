
import UIKit
import ParseUI

protocol UserTableViewCellDelegate:class {
    func cellActivated()
}

class UserTableViewCell: PFTableViewCell {


    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pfImageView: PFImageView!
    
    var following:Bool = false
    var user:User!
    weak var delegate:UserTableViewCellDelegate?
    
    func configure(user:User) {
        setFollow(false, enabled: false)
        self.user = user
        nameLabel.text = user.username
        nameLabel.textColor = Constants.usernameTextPrimaryColor
        nameLabel.backgroundColor = UIColor.clearColor()
        
        pfImageView.file = user.picture
        pfImageView.image = UIImage(named: "Avatar.png")
        pfImageView.loadInBackground()
        pfImageView.layer.cornerRadius = pfImageView.frame.size.height/2
        pfImageView.layer.masksToBounds = true
        pfImageView.backgroundColor = UIColor.lightGrayColor()
        pfImageView.layer.borderWidth = 5
        pfImageView.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
        
        if user.isUs() {
            setFollow(false, enabled: false)
        }
    }
    
    func setFollow(isFollowing:Bool, enabled:Bool) {
        self.following = isFollowing
        if following {
            self.accessoryView = nil
            self.accessoryType = .Checkmark
        } else {
            self.accessoryType = .None
            let button = UIButton(type: .ContactAdd)
            button.addTarget(self, action: "followUser", forControlEvents: .TouchUpInside)
            button.enabled = enabled
            self.accessoryView = button
        }
    }
    
    func followUser() {
        delegate?.cellActivated()
        setFollow(true, enabled: true)
    }
    
    override func drawRect(rect: CGRect) {
        pfImageView.layer.cornerRadius = pfImageView.frame.size.height/2
    }
}
