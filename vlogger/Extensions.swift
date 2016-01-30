//
//  Extensions.swift
//  vlogger
//
//  Created by Eric Smith on 1/12/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import Foundation
import ParseUI
import UIKit

extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: self, toDate: date, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: self, toDate: date, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: self, toDate: date, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: self, toDate: date, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: self, toDate: date, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: self, toDate: date, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: self, toDate: date, options: []).second
    }
    
    func getReadableTime() -> String {
        let date = NSDate()
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        return "0m"
    }
    
    func getReadableTimeForChat() -> String {
        let formatter = NSDateFormatter()
        var returnString = ""
        let days = daysFrom(NSDate())
        if days > 0 {
            formatter.dateFormat = "MMM d"
            returnString = formatter.stringFromDate(self)
        } else {
            formatter.dateFormat = "h:mm a"
            returnString = formatter.stringFromDate(self)
        }
        return returnString
    }
    
    class func getReadableTimeFromDay(day:Int) -> String {
        let formatter = NSDateFormatter()
        let hour = day*24
        let minute = hour*60
        let second = minute*60
        let date = NSDate(timeIntervalSince1970:  NSTimeInterval(second))
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.stringFromDate(date)
    }
    
    class func getReadableTimeFull() -> String {
        let formatter = NSDateFormatter()
        let date = NSDate()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.stringFromDate(date)
    }
    
    class func getCurrentDay() -> Int {
        return NSDate(timeIntervalSince1970: 0).daysFrom(NSDate())
    }
    
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        return isGreater
    }
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool {
        var isLess = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        return isLess
    }
    
    func addDays(daysToAdd : Int) -> NSDate {
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        return dateWithDaysAdded
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
    
    func toImage(size:CGSize) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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

extension NSData
{
    func imageFileSize() -> String {
        return "\( Double(self.length) * pow(Double(10.0), Double(-6.0)) ) MB"
    }
}

extension UITableView {
    func scrollToBottom(animated: Bool) {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.tableViewDoBottomScroll(animated)
        })
    }
    
    private func tableViewDoBottomScroll(animated: Bool) {
        let numberOfRows = self.numberOfRowsInSection(0)
        if numberOfRows > 0 {
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: 0)
            self.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
        }
    }
    
    func refreshControlBackground(color:UIColor) {
        var frame = self.bounds
        frame.origin.y = -frame.size.height
        let refreshControlBackgroundView = UIView(frame: frame)
        refreshControlBackgroundView.backgroundColor = color
        self.insertSubview(refreshControlBackgroundView, atIndex: 0)
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
}

extension Int {
    func pretty() -> String {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        return numberFormatter.stringFromNumber(self)!
    }
}