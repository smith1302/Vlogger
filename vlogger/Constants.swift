import UIKit
import CoreGraphics

class Constants {
    static let appName = "Selfiesteem"
    static let storyboard = UIStoryboard(name: "Main", bundle: nil) //  Get storyboars singleton
    static let primaryColor = UIColor(hex: 0x56E38C)
    static let darkPrimaryColor = UIColor(hex: 0x4BC97B)
    static let lightPrimaryColor = UIColor(hex: 0x5CFA99)
    static let superLightPrimaryColor = UIColor(hex: 0xE3FFEA)
    static let secondaryColor = UIColor(hex: 0x84EEFA)
    class func primaryColorWithAlpha(alpha:CGFloat) -> UIColor {
        return UIColor(hex: 0x55B34B, alpha: alpha)
    }
    static let testMode:Bool = true
    
    // Objects 
    struct Objects {
        static let kFollowing = "Following"
    }
}