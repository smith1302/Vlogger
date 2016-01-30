//
//  UIButtonOutline.swift
//  vlogger
//
//  Created by Eric Smith on 1/6/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class UIButtonOutline: UIButton {
    
    init(image:UIImage, frame:CGRect) {
        super.init(frame: frame)
        imageView?.contentMode = .ScaleAspectFit
        setImage(image, forState: .Normal)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setImage(imageView?.image, forState: .Normal)
        customInit()
    }
    
    func customInit() {
        let blurSize:CGFloat = 3
        let blurColor = UIColor(white: 0.2, alpha: 0.8)
        // Configure post image controls
        if let _ = titleLabel?.text {
            setTitleShadowColor(blurColor, forState: .Normal)
            layer.shadowOffset = CGSize(width: 0, height: 1)
            layer.shadowRadius = blurSize/3
            layer.shadowOpacity = 0.8
        }
    }
    
    override func setImage(image: UIImage?, forState state: UIControlState) {
        
        let blurSize:CGFloat = 3
        let blurColor = UIColor(white: 0.2, alpha: 0.8)
        var newImage = image
        
        if let source = image {
            let data : UnsafeMutablePointer<Void> = nil
            let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()!
            let bitmapInfo : CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
            
            let myColor = blurColor.CGColor
            
            CGBitmapContextCreate(data, Int(source.size.width), Int(source.size.height), 8, 0, colorSpace, bitmapInfo.rawValue)
            let shadowContext : CGContextRef = CGBitmapContextCreate(data, Int(source.size.width + blurSize), Int(source.size.height + blurSize), CGImageGetBitsPerComponent(source.CGImage), 0, colorSpace, bitmapInfo.rawValue)!
            
            CGContextSetShadowWithColor(shadowContext, CGSize(width: blurSize/2,height: -blurSize/2),  blurSize, myColor)
            CGContextDrawImage(shadowContext, CGRect(x: 0, y: blurSize, width: source.size.width, height: source.size.height), source.CGImage)
            
            let shadowedCGImage : CGImageRef = CGBitmapContextCreateImage(shadowContext)!
            newImage = UIImage(CGImage: shadowedCGImage)
        }
        
        super.setImage(newImage, forState: state)
    }

}
