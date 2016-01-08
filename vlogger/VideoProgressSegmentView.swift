//
//  VideoProgressSegmentView.swift
//  vlogger
//
//  Created by Eric Smith on 1/6/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit

class VideoProgressSegmentView: UIView {
    
    var fillView:UIView?
    var currentFillPercent:CGFloat
    
    override init(frame: CGRect) {
        currentFillPercent = 0
        super.init(frame: frame)
        backgroundColor = UIColor(white: 1, alpha: 0.3)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFillPercent(var percent:CGFloat) {
        percent = min(max(0, percent),1)
        if currentFillPercent == percent {
            return
        }
        currentFillPercent = percent
        if fillView == nil {
            fillView = UIView(frame: self.bounds)
            fillView?.backgroundColor = UIColor(white: 1, alpha: 0.4)
            addSubview(fillView!)
        }
        fillView!.frame.size.width = frame.size.width*currentFillPercent
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
