//
//  FaceDetectionView.swift
//  Selfiesteem
//
//  Created by Eric Smith on 12/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import UIKit

class FaceDetectionView : UIView {
    
    let fadeDuration:NSTimeInterval = 0.3
    var isAnimating = false
    var untracked:Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func customInit() {
        layer.borderColor = UIColor.yellowColor().CGColor
        layer.borderWidth = 2
    }
    
    // Show detector if we dont have them tracked
    func showAtFrame(frame:CGRect) {
        if untracked {
            self.frame = frame
        } else {
            UIView.animateWithDuration(0.1, animations: {
                self.frame = frame
            })
            return
        }
        untracked = false
        alpha = 1
        animateAlpha(0  , withDelay: 0.7)
    }
    
    func didFrameChanged(newFrame:CGRect) -> Bool {
        return !(newFrame.origin.x == frame.origin.x || newFrame.origin.y == frame.origin.y || newFrame.size.width == frame.size.width || newFrame.size.height == frame.size.height)
    }
    
    func hide() {
        untracked = true
        isAnimating = false
        self.frame = CGRectZero
    }
    
    func animateAlpha(alpha:CGFloat, withDelay delay:NSTimeInterval) {
        if isAnimating {
            return
        }
        isAnimating = true
        UIView.animateWithDuration(fadeDuration, delay: delay, options: .CurveEaseIn, animations: {
            self.alpha = alpha
            }, completion: {
                (done:Bool) in
                self.isAnimating = false
        })
    }
    
}