//
//  UIImageViewOutline.swift
//  vlogger
//
//  Created by Eric Smith on 1/23/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class UIImageViewOutline: UIImageView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let blurSize:CGFloat = 3
        let blurColor = UIColor(white: 0.2, alpha: 0.5)
        
        if let source = image {
            let data : UnsafeMutablePointer<Void> = nil
            let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()!
            let bitmapInfo : CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
            
            let myColor = blurColor.CGColor
            
            _ = CGBitmapContextCreate(data, Int(source.size.width), Int(source.size.height), 8, 0, colorSpace, bitmapInfo.rawValue)
            let shadowContext : CGContextRef = CGBitmapContextCreate(data, Int(source.size.width + blurSize), Int(source.size.height + blurSize), CGImageGetBitsPerComponent(source.CGImage), 0, colorSpace, bitmapInfo.rawValue)!
            
            CGContextSetShadowWithColor(shadowContext, CGSize(width: blurSize/2,height: -blurSize/2),  blurSize, myColor)
            CGContextDrawImage(shadowContext, CGRect(x: 0, y: blurSize, width: source.size.width, height: source.size.height), source.CGImage)
            
            let shadowedCGImage : CGImageRef = CGBitmapContextCreateImage(shadowContext)!
            let shadowedImage : UIImage = UIImage(CGImage: shadowedCGImage)
            
            image = shadowedImage
        }
    }

}
