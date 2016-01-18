//
//  VideoSaveOverlayView.swift
//  vlogger
//
//  Created by Eric Smith on 1/4/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

protocol VideoSaveOverlayDelegate {
    func cancelPressed()
    func continuePressed()
}

class VideoSaveOverlayView: UIView {
    
    let xButton:UIButton
    let nextButton:UIButton
    let padding:CGFloat = 12
    var delegate:VideoSaveOverlayDelegate?

    override init(frame: CGRect) {
        
        xButton = UIButton()
        nextButton = UIButton()
        
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.1, alpha: 0.4)
        
        let buttonHeight:CGFloat = frame.size.height-padding*2
        
        let xImage = UIImage(named: "X.png")
        xButton.setImage(xImage, forState: .Normal)
        xButton.frame = CGRectMake(padding, 0, buttonHeight, buttonHeight)
        xButton.center.y = frame.size.height/2
        
        let nextImage = UIImage(named: "Next.png")
        nextButton.setImage(nextImage, forState: .Normal)
        nextButton.frame = CGRectMake(frame.size.width-buttonHeight-padding, 0, buttonHeight, buttonHeight)
        nextButton.center.y = xButton.center.y
        
        xButton.addTarget(self, action: "cancelPressed", forControlEvents: .TouchUpInside)
        nextButton.addTarget(self, action: "continuePressed", forControlEvents: .TouchUpInside)
        
        addSubview(xButton)
        addSubview(nextButton)
        
        transform = CGAffineTransformMakeTranslation(0, frame.size.height)
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.transform = CGAffineTransformMakeTranslation(0, 0)
        }, completion: nil)
    }
    
    func cancelPressed() {
        remove()
        delegate?.cancelPressed()
    }
    
    func continuePressed() {
        remove()
        delegate?.continuePressed()
    }
    
    func remove() {
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseIn, animations: {
            self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height)
            }, completion: {
                (finished) in
                self.removeFromSuperview()
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
