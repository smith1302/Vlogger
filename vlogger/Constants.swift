import UIKit
import CoreGraphics

let kPhotoUploadSuccess = "Video has been added!"

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
}

extension NSDate {
    func calenderComponentDifference(toDateTime: NSDate, inTimeZone timeZone: NSTimeZone? = nil) -> NSDateComponents {
        let calendar = NSCalendar.currentCalendar()
        if let timeZone = timeZone {
            calendar.timeZone = timeZone
        }
        
        var fromDate: NSDate?, toDate: NSDate?
        
        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: self)
        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: toDateTime)
        
        let difference = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: [])
        return difference
    }
}

extension UIColor {
    convenience init(hex:Int) {
        self.init(hex: hex, alpha: 1)
    }
    
    convenience init(hex:Int, alpha:CGFloat) {
        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}

extension String {
    func hasWhitespace() -> Bool {
        let whitespace = NSCharacterSet.whitespaceCharacterSet()
        let range = self.rangeOfCharacterFromSet(whitespace)
        return range != nil
    }
    
    func stripWhitespace() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    static func randomStringWithLength (len : Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for (var i=0; i < len; i++){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        return randomString as String
    }
}

extension NSDate
{
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    
    func addDays(daysToAdd : Int) -> NSDate
    {
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
}