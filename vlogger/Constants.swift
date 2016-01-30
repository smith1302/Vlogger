import UIKit
import CoreGraphics

class Constants {
    static let appName = "Selfiesteem"
    static let storyboard = UIStoryboard(name: "Main", bundle: nil) //  Get storyboard singleton
    
    static let primaryColor = UIColor(hex: 0xFC5961)
    static let primaryColorDark = UIColor(hex: 0xE0434B)
    static let primaryColorSoft = UIColor(hex: 0xDAE8F2)
    static let secondaryColor = UIColor(hex: 0x2cb87b)
    static let textOnPrimaryColor = UIColor(hex: 0xFFFFFF)
    static let usernameTextPrimaryColor = UIColor(hex: 0x196DB5)
    static let testMode:Bool = true
    
    // Objects 
    struct Objects {
        static let kFollowing = "Following"
    }
}